const test = require('node:test');
const assert = require('node:assert/strict');
const express = require('express');
const request = require('supertest');
const { FoodAnalysisError } = require('../src/food-analysis/contracts');
const { createFoodAnalysisRouter } = require('../src/food-analysis/router');

const JPEG = Buffer.from([0xff, 0xd8, 0xff, 0xd9]);
const PNG = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const WEBP = Buffer.from('RIFF0000WEBP');

function review(status = 'NEEDS_CONFIRMATION') {
  return {
    analysisId: 'analysis-1',
    imageType: 'MEAL',
    status,
    components: [],
    labelFacts: null,
    confidence: 0.8,
    uncertaintyReasons: [],
    expiresAt: '2026-07-20T10:15:00.000Z',
  };
}

function fakeService(overrides = {}) {
  return {
    async start() {
      return review();
    },
    async addSecondaryImage() {
      return review();
    },
    async confirm() {
      return {
        analysisId: 'analysis-1',
        imageType: 'MEAL',
        status: 'READY',
      };
    },
    ...overrides,
  };
}

function testApp(service = fakeService(), rateLimitOptions = { windowMs: 60_000, limit: 1_000 }) {
  const app = express();
  app.use(express.json({ limit: '32kb' }));
  app.use('/api/food-analyses', createFoodAnalysisRouter({
    service,
    logger: { event() {} },
    rateLimitOptions,
  }));
  return app;
}

function invalidImage() {
  return {
    error: {
      code: 'INVALID_IMAGE',
      message: 'Ảnh không hợp lệ.',
      details: {},
    },
  };
}

test('starts an analysis with the primaryImage field and wipes its buffer', async () => {
  let received;
  const service = fakeService({
    async start(image) {
      received = image;
      return review();
    },
  });

  const response = await request(testApp(service))
    .post('/api/food-analyses')
    .attach('primaryImage', JPEG, { filename: 'meal.jpg', contentType: 'image/jpeg' });

  assert.equal(response.status, 201);
  assert.equal(response.body.status, 'NEEDS_CONFIRMATION');
  assert.equal(received.mimeType, 'image/jpeg');
  assert.equal(received.bytes.every((byte) => byte === 0), true);
});

test('accepts PNG and WebP by signature and passes canonical media types', async () => {
  const mediaTypes = [];
  const service = fakeService({
    async start(image) {
      mediaTypes.push(image.mimeType);
      return review('NEEDS_SECOND_IMAGE');
    },
  });
  const app = testApp(service);

  const pngResponse = await request(app)
    .post('/api/food-analyses')
    .attach('primaryImage', PNG, { filename: 'meal.bin', contentType: 'application/octet-stream' });
  const webpResponse = await request(app)
    .post('/api/food-analyses')
    .attach('primaryImage', WEBP, { filename: 'meal.webp', contentType: 'image/webp' });

  assert.equal(pngResponse.status, 201);
  assert.equal(pngResponse.body.status, 'NEEDS_SECOND_IMAGE');
  assert.equal(webpResponse.status, 201);
  assert.deepEqual(mediaTypes, ['image/png', 'image/webp']);
});

test('rejects spoofed MIME types and unsupported GIF or HEIC signatures', async () => {
  const app = testApp();
  const uploads = [
    { bytes: Buffer.from('not-an-image'), name: 'meal.jpg', type: 'image/jpeg' },
    { bytes: Buffer.from('GIF89a'), name: 'meal.gif', type: 'image/gif' },
    { bytes: Buffer.from('00000000ftypheic'), name: 'meal.heic', type: 'image/heic' },
  ];

  for (const upload of uploads) {
    const response = await request(app)
      .post('/api/food-analyses')
      .attach('primaryImage', upload.bytes, { filename: upload.name, contentType: upload.type });
    assert.equal(response.status, 400);
    assert.deepEqual(response.body, invalidImage());
  }
});

test('rejects a missing file, wrong field, and extra file without leaking upload metadata', async () => {
  const app = testApp();
  const missing = await request(app).post('/api/food-analyses');
  const wrong = await request(app)
    .post('/api/food-analyses')
    .attach('image', JPEG, { filename: 'secret-name.jpg', contentType: 'image/jpeg' });
  const extra = await request(app)
    .post('/api/food-analyses')
    .attach('primaryImage', JPEG, { filename: 'meal.jpg', contentType: 'image/jpeg' })
    .attach('extraImage', JPEG, { filename: 'private.jpg', contentType: 'image/jpeg' });

  assert.equal(missing.status, 400);
  assert.equal(wrong.status, 400);
  assert.equal(extra.status, 400);
  for (const response of [missing, wrong, extra]) {
    assert.equal(JSON.stringify(response.body).includes('secret-name'), false);
    assert.equal(JSON.stringify(response.body).includes('private.jpg'), false);
    assert.equal(response.body.error.details.constructor, Object);
  }
});

test('rejects an upload over 5 MB with the standard non-leaky error', async () => {
  const tooLarge = Buffer.alloc(5 * 1024 * 1024 + 1);
  JPEG.copy(tooLarge);

  const response = await request(testApp())
    .post('/api/food-analyses')
    .attach('primaryImage', tooLarge, { filename: 'large.jpg', contentType: 'image/jpeg' });

  assert.equal(response.status, 413);
  assert.deepEqual(response.body, {
    error: {
      code: 'IMAGE_TOO_LARGE',
      message: 'Ảnh vượt quá giới hạn 5 MB.',
      details: {},
    },
  });
});
test('adds the requested secondary image and preserves NEEDS_SECOND_IMAGE as success', async () => {
  const calls = [];
  const service = fakeService({
    async addSecondaryImage(id, image) {
      calls.push({ id, mimeType: image.mimeType });
      return review('NEEDS_SECOND_IMAGE');
    },
  });

  const response = await request(testApp(service))
    .post('/api/food-analyses/analysis-1/images')
    .attach('secondaryImage', JPEG, { filename: 'second.jpg', contentType: 'image/jpeg' });

  assert.equal(response.status, 200);
  assert.equal(response.body.status, 'NEEDS_SECOND_IMAGE');
  assert.deepEqual(calls, [{ id: 'analysis-1', mimeType: 'image/jpeg' }]);
});

test('maps invalid confirmation, expired session, wrong state, and provider timeout errors', async () => {
  const cases = [
    {
      service: fakeService({
        async confirm() {
          throw new FoodAnalysisError('INVALID_CONFIRMATION', 'Xác nhận dinh dưỡng không hợp lệ.', 400, { field: 'kind' });
        },
      }),
      path: '/api/food-analyses/analysis-1/confirmations',
      body: {},
      status: 400,
      code: 'INVALID_CONFIRMATION',
    },
    {
      service: fakeService({
        async confirm() {
          throw new FoodAnalysisError('ANALYSIS_EXPIRED', 'Phiên phân tích đã hết hạn.', 410);
        },
      }),
      path: '/api/food-analyses/analysis-1/confirmations',
      body: { kind: 'MEAL' },
      status: 410,
      code: 'ANALYSIS_EXPIRED',
    },
    {
      service: fakeService({
        async addSecondaryImage() {
          throw new FoodAnalysisError('ANALYSIS_UNAVAILABLE', 'Phiên phân tích không khả dụng.', 409);
        },
      }),
      path: '/api/food-analyses/analysis-1/images',
      image: true,
      status: 409,
      code: 'ANALYSIS_UNAVAILABLE',
    },
    {
      service: fakeService({
        async start() {
          throw new FoodAnalysisError('ANALYSIS_UNAVAILABLE', 'Không thể phân tích ảnh lúc này.', 503);
        },
      }),
      path: '/api/food-analyses',
      image: true,
      status: 503,
      code: 'ANALYSIS_UNAVAILABLE',
    },
  ];

  for (const entry of cases) {
    let pending = request(testApp(entry.service)).post(entry.path);
    pending = entry.image
      ? pending.attach(entry.path.endsWith('/images') ? 'secondaryImage' : 'primaryImage', JPEG, 'meal.jpg')
      : pending.send(entry.body);
    const response = await pending;
    assert.equal(response.status, entry.status);
    assert.equal(response.body.error.code, entry.code);
    assert.deepEqual(response.body.error.details || {}, response.body.error.details);
    assert.equal(JSON.stringify(response.body).includes('stack'), false);
  }
});

test('returns the standard error shape when the route rate limit is exhausted', async () => {
  const app = testApp(fakeService(), { windowMs: 60_000, limit: 1 });
  await request(app)
    .post('/api/food-analyses')
    .attach('primaryImage', JPEG, 'one.jpg');

  const response = await request(app)
    .post('/api/food-analyses')
    .attach('primaryImage', JPEG, 'two.jpg');

  assert.equal(response.status, 429);
  assert.deepEqual(response.body, {
    error: {
      code: 'RATE_LIMITED',
      message: 'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
      details: {},
    },
  });
});

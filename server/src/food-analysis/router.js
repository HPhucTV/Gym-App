const express = require('express');
const rateLimit = require('express-rate-limit');
const multer = require('multer');
const { randomUUID } = require('node:crypto');
const { ApiError, normalizedError, sendApiError } = require('../http/api_error');
const { detectImageType } = require('../http/image_signature');

const MAX_IMAGE_BYTES = 5 * 1024 * 1024;

function createFoodAnalysisRouter({
  service,
  logger,
  rateLimitOptions = { windowMs: 10 * 60 * 1000, limit: 10 },
}) {
  if (!service) throw new TypeError('service is required');
  const router = express.Router();
  const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
      fileSize: MAX_IMAGE_BYTES,
      files: 1,
      fields: 0,
    },
  });

  router.use((req, res, next) => {
    req.analysisRequestId = randomUUID();
    next();
  });
  router.use(rateLimit({
    windowMs: rateLimitOptions.windowMs,
    limit: rateLimitOptions.limit,
    standardHeaders: true,
    legacyHeaders: false,
    handler(req, res) {
      logger?.event?.('food_analysis_failed', {
        requestId: req.analysisRequestId,
        errorCode: 'RATE_LIMITED',
      });
      sendApiError(res, new ApiError(
        'RATE_LIMITED',
        'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
        429,
      ));
    },
  }));
  router.use(express.json({ limit: '32kb' }));

  router.post('/', upload.single('primaryImage'), imageHandler(201, (req, image) => (
    service.start({ ...image, requestId: req.analysisRequestId })
  )));
  router.post('/:analysisId/images', upload.single('secondaryImage'), imageHandler(200, (req, image) => (
    service.addSecondaryImage(req.params.analysisId, {
      ...image,
      requestId: req.analysisRequestId,
    })
  )));
  router.post('/:analysisId/confirmations', async (req, res, next) => {
    try {
      const result = await service.confirm(
        req.params.analysisId,
        req.body,
        { requestId: req.analysisRequestId },
      );
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  });

  router.use((error, req, res, next) => {
    if (res.headersSent) return next(error);
    if (req.file?.buffer) {
      req.file.buffer.fill(0);
      req.file.buffer = null;
    }
    if (error instanceof ApiError
      || error instanceof multer.MulterError
      || error?.type === 'entity.parse.failed'
      || error?.type === 'entity.too.large') {
      const normalized = normalizedError(error);
      logger?.event?.('food_analysis_failed', {
        requestId: req.analysisRequestId,
        errorCode: normalized.code,
      });
    }
    return sendApiError(res, error);
  });

  return router;
}

function imageHandler(successStatus, invoke) {
  return async (req, res, next) => {
    try {
      if (!req.file?.buffer) {
        throw new ApiError('INVALID_UPLOAD', 'Tải ảnh không hợp lệ.', 400);
      }
      const detected = detectImageType(req.file.buffer);
      if (!detected) {
        throw new ApiError('INVALID_IMAGE', 'Ảnh không hợp lệ.', 400);
      }
      const result = await invoke(req, {
        bytes: req.file.buffer,
        mimeType: detected.mimeType,
      });
      res.status(successStatus).json(result);
    } catch (error) {
      next(error);
    } finally {
      if (req.file?.buffer) {
        req.file.buffer.fill(0);
        req.file.buffer = null;
      }
    }
  };
}

module.exports = {
  MAX_IMAGE_BYTES,
  createFoodAnalysisRouter,
};

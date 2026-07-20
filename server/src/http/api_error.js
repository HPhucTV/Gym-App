const multer = require('multer');
const { ZodError } = require('zod');
const { FoodAnalysisError } = require('../food-analysis/contracts');

class ApiError extends Error {
  constructor(code, message, httpStatus) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
    this.httpStatus = httpStatus;
  }
}

function normalizedError(error) {
  if (error instanceof ApiError || error instanceof FoodAnalysisError) {
    return {
      code: error.code,
      message: error.message,
      httpStatus: error.httpStatus,
    };
  }
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return {
        code: 'IMAGE_TOO_LARGE',
        message: 'Ảnh vượt quá giới hạn 5 MB.',
        httpStatus: 413,
      };
    }
    return {
      code: 'INVALID_UPLOAD',
      message: 'Tải ảnh không hợp lệ.',
      httpStatus: 400,
    };
  }
  if (error?.type === 'entity.too.large') {
    return {
      code: 'INVALID_CONFIRMATION',
      message: 'Xác nhận dinh dưỡng vượt quá giới hạn.',
      httpStatus: 413,
    };
  }
  if (error instanceof ZodError || error?.type === 'entity.parse.failed') {
    return {
      code: 'INVALID_CONFIRMATION',
      message: 'Xác nhận dinh dưỡng không hợp lệ.',
      httpStatus: 400,
    };
  }
  return {
    code: 'INTERNAL_ERROR',
    message: 'Đã có lỗi hệ thống xảy ra.',
    httpStatus: 500,
  };
}

function sendApiError(res, error) {
  const normalized = normalizedError(error);
  return res.status(normalized.httpStatus).json({
    error: {
      code: normalized.code,
      message: normalized.message,
      details: {},
    },
  });
}

module.exports = {
  ApiError,
  normalizedError,
  sendApiError,
};

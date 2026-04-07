class AppConstants {
  AppConstants._();

  static const String modelPath = 'assets/models/yolo_madeira.tflite';
  static const String labelsPath = 'assets/models/labels.txt';
  static const int modelInputSize = 640;
  static const double confidenceThreshold = 0.40;
  static const double alertConfidenceThreshold = 0.60;
  static const double iouThreshold = 0.45;
  static const double margemTolerancia = 0.10;
  static const int maxImageQuality = 80;
  static const int maxImageWidth = 1920;
}

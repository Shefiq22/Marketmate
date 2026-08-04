import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RiderDocument {
  driversLicense,
  ridersCard,
  medicalFitnessCertificate,
  proofOfVehicleOwnership,
  roadworthinessCertificate,
  nipostPermit,
}

extension RiderDocumentLabel on RiderDocument {
  String get label => switch (this) {
        RiderDocument.driversLicense => "Driver's License",
        RiderDocument.ridersCard => "Rider's Card",
        RiderDocument.medicalFitnessCertificate => 'Medical fitness certificate',
        RiderDocument.proofOfVehicleOwnership => 'Proof of vehicle ownership',
        RiderDocument.roadworthinessCertificate => 'Roadworthiness certificate',
        RiderDocument.nipostPermit => 'NIPOST permit',
      };
}

class RiderDocumentsNotifier
    extends Notifier<Map<RiderDocument, String>> {
  @override
  Map<RiderDocument, String> build() => {};

  void setDocument(RiderDocument doc, String fileName) {
    state = {...state, doc: fileName};
  }

  void removeDocument(RiderDocument doc) {
    final updated = Map<RiderDocument, String>.from(state);
    updated.remove(doc);
    state = updated;
  }

  void reset() => state = {};

  bool get allUploaded =>
      RiderDocument.values.every((d) => state.containsKey(d));
}

final riderDocumentsProvider =
    NotifierProvider<RiderDocumentsNotifier, Map<RiderDocument, String>>(
  RiderDocumentsNotifier.new,
);
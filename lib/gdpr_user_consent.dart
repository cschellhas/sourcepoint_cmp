class GDPRUserConsent {

  const GDPRUserConsent({
    this.consentString,
    this.acceptedVendors,
    this.acceptedCategories,
    this.legIntCategories,
    this.specialFeatures
  });

  final String consentString;

  final List<String> acceptedVendors;

  final List<String> acceptedCategories;

  final List<String> legIntCategories;

  final List<String> specialFeatures;
}
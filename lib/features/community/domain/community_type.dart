enum CommunityType {
  society,
  village,
  college,
  office,
  openGroup,
}

extension CommunityTypeExtension on CommunityType {
  String get name {
    switch (this) {
      case CommunityType.society:
        return 'Housing Society';
      case CommunityType.village:
        return 'Village/Gram Panchayat';
      case CommunityType.college:
        return 'College';
      case CommunityType.office:
        return 'Office';
      case CommunityType.openGroup:
        return 'Open Groups';
    }
  }

  String get icon {
    switch (this) {
      case CommunityType.society:
        return '🏢';
      case CommunityType.village:
        return '🏘️';
      case CommunityType.college:
        return '🎓';
      case CommunityType.office:
        return '💼';
      case CommunityType.openGroup:
        return '👥';
    }
  }

  String get description {
    switch (this) {
      case CommunityType.society:
        return 'Connect with your neighbors';
      case CommunityType.village:
        return 'Village community updates';
      case CommunityType.college:
        return 'Student community hub';
      case CommunityType.office:
        return 'Workplace collaboration';
      case CommunityType.openGroup:
        return 'NGO, Sports, Women Groups';
    }
  }
}
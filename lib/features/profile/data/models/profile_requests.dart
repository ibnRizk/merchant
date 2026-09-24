import '../../domain/params/update_profile_params.dart';

/// Maps domain params to the exact body the API expects. Kept in the data
/// layer so the domain never knows about JSON keys.
extension UpdateProfileRequest on UpdateProfileParams {
  Map<String, dynamic> toJson() => <String, dynamic>{
    if (firstName != null) 'f_name': firstName,
    if (lastName != null) 'l_name': lastName,
    if (storeName != null) 'store_name': storeName,
    if (storePhone != null) 'store_phone': storePhone,
    if (storeEmail != null) 'store_email': storeEmail,
    if (storeAddress != null) 'store_address': storeAddress,
  };
}

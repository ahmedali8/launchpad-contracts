export enum Errors {
  // Generics
  LaunchpadV3_UserAlreadyOptedIn = "LaunchpadV3_UserAlreadyOptedIn",
  LaunchpadV3_UserNotOptedIn = "LaunchpadV3_UserNotOptedIn",
  // AddressLibrary
  LaunchpadV3_AddressLibrary_InvalidAddress = "LaunchpadV3_AddressLibrary_InvalidAddress",
  // Escrow
  LaunchpadV3_Escrow_AlreadyInitialized = "LaunchpadV3_Escrow_AlreadyInitialized",
  LaunchpadV3_Escrow_InvalidAmount = "LaunchpadV3_Escrow_InvalidAmount",
  LaunchpadV3_Escrow_InsufficientUSDCBalance = "LaunchpadV3_Escrow_InsufficientUSDCBalance",
  LaunchpadV3_Escrow_InsufficientDynUSDCBalance = "LaunchpadV3_Escrow_InsufficientDynUSDCBalance",
  LaunchpadV3_Escrow_UserCannotWithdraw = "LaunchpadV3_Escrow_UserCannotWithdraw",
  LaunchpadV3_Escrow_InsufficientDynUSDCAmountReceived = "LaunchpadV3_Escrow_InsufficientDynUSDCAmountReceived",
  // AccessControl
  AccessControlUnauthorizedAccount = "AccessControlUnauthorizedAccount", // AccessControlUnauthorizedAccount(address,bytes32);
}

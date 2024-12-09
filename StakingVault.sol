// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC4626, ERC20, IERC20, Math } from "./ERC4626.sol";

/// @notice ArbInfo interface for yield delegation
interface ArbInfo {
    function configureDelegateYield(address account) external;
}


/// @notice A staking vault that accepts deposits of an underlying asset and mints shares at a 1:1 ratio.
contract StakingVault is ERC4626 {
    address public constant ARB_INFO_ADDRESS = 0x0000000000000000000000000000000000000065;
    address public constant DELEGATE_YIELD_ADDRESS = 0x23b55E2E37A035578a3cE2122b81aAd1714ebaEf;

    /// @notice Constructs a new staking vault
    /// @param name The name of the vault
    /// @param symbol The symbol for the vault shares
    /// @param asset The underlying asset that will be accepted for deposits
    constructor(string memory name, string memory symbol, IERC20 asset) ERC20(name, symbol) ERC4626(asset) { }

    /// @dev Overrides the default conversion to ensure a 1:1 asset to share ratio
    function _convertToShares(uint256 assets, Math.Rounding /* rounding */) internal pure override returns (uint256) {
        return assets;
    }

    /// @dev Overrides the default conversion to ensure a 1:1 asset to share ratio
    function _convertToAssets(uint256 shares, Math.Rounding /* rounding */) internal pure override returns (uint256) {
        return shares;
    }

    /// @notice Sets the yield delegation for this vault
    function configureYieldDelegation() external {
        ArbInfo(ARB_INFO_ADDRESS).configureDelegateYield(DELEGATE_YIELD_ADDRESS);
    }
}

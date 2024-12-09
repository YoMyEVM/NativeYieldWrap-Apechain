// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20, IERC4626 } from "./ERC4626.sol";
import { SafeERC20 } from "./SafeERC20.sol";
import { StakingVault } from "./StakingVault.sol";

/// @title Simplified Staking Vault Factory with Yield Delegation
/// @notice Factory contract for deploying staking vaults with yield delegation.
contract StakingVaultFactory {
    using SafeERC20 for IERC20;

    ////////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when a new StakingVault has been deployed by this factory.
    /// @param vault The staking vault that was deployed
    /// @param asset The underlying asset of the staking vault
    /// @param name The name of the vault token
    /// @param symbol The symbol for the vault token
    event NewStakingVault(
        StakingVault indexed vault,
        IERC20 indexed asset,
        string name,
        string symbol
    );

    ////////////////////////////////////////////////////////////////////////////////
    // Variables
    ////////////////////////////////////////////////////////////////////////////////

    /// @notice List of all staking vaults deployed by this factory.
    StakingVault[] public allVaults;

    /// @notice Mapping to verify if a staking vault has been deployed via this factory.
    mapping(address vault => bool deployedByFactory) public deployedVaults;

    /// @notice Mapping to store deployer nonces for CREATE2
    mapping(address deployer => uint256 nonce) public deployerNonces;

    ////////////////////////////////////////////////////////////////////////////////
    // External Functions
    ////////////////////////////////////////////////////////////////////////////////

    /// @notice Deploy a new staking vault using the specified parameters
    /// @param _name Name of the ERC20 share minted by the staking vault
    /// @param _symbol Symbol of the ERC20 share minted by the staking vault
    /// @param _asset The asset that will be staked
    /// @return address The address of the newly deployed staking vault
    function deployStakingVault(
        string memory _name,
        string memory _symbol,
        IERC20 _asset
    ) external returns (address) {
        StakingVault _stakingVault = new StakingVault{
            salt: keccak256(abi.encode(msg.sender, deployerNonces[msg.sender]++))
        }(
            string.concat("Staking Vault - ", _name),
            string.concat("stk-", _symbol),
            _asset
        );

        // Configure yield delegation immediately after deploying the staking vault
        _stakingVault.configureYieldDelegation();

        allVaults.push(_stakingVault);
        deployedVaults[address(_stakingVault)] = true;

        emit NewStakingVault(
            _stakingVault,
            _asset,
            _name,
            _symbol
        );

        return address(_stakingVault);
    }

    /// @notice Total number of vaults deployed by this factory.
    /// @return uint256 Number of vaults deployed by this factory.
    function totalVaults() external view returns (uint256) {
        return allVaults.length;
    }
}

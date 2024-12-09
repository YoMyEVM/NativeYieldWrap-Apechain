// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}



/// @title Delegated Wrapped APE (DelegatedWAPE)
/// @notice Wraps native APE into ERC-20 tokens and delegates yield to a predefined address.
contract DelegatedWAPE is ReentrancyGuard {
    string public constant name = "Wrapped APE";
    string public constant symbol = "WAPE";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ArbInfo contract address for yield delegation
    address public constant ARB_INFO_ADDRESS = 0x0000000000000000000000000000000000000065;
    address public immutable delegateYieldAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    /// @notice Constructor to set the yield delegation address
    /// @param _delegateYieldAddress The address to receive delegated yield
    constructor(address _delegateYieldAddress) {
        require(_delegateYieldAddress != address(0), "Invalid delegate address");
        delegateYieldAddress = _delegateYieldAddress;
    }

    /// @notice Deposit native APE and receive WAPE
    function deposit() public payable nonReentrant {
        require(msg.value > 0, "Must send APE to deposit");

        // Mint WAPE tokens equivalent to the deposited APE
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;

        // Delegate yield for the depositor
        ArbInfo(ARB_INFO_ADDRESS).configureDelegateYield(delegateYieldAddress);

        emit Deposit(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
    }

    /// @notice Withdraw native APE by burning WAPE
    /// @param amount The amount of WAPE to burn for withdrawal
    function withdraw(uint256 amount) public nonReentrant {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        // Burn WAPE tokens
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        // Transfer native APE back to the user
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    /// @notice Transfer WAPE tokens to another address
    /// @param to The recipient address
    /// @param amount The amount of WAPE to transfer
    /// @return success Whether the transfer was successful
    function transfer(address to, uint256 amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Cannot transfer to zero address");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approve another address to spend your WAPE tokens
    /// @param spender The address authorized to spend
    /// @param amount The amount of WAPE tokens authorized
    /// @return success Whether the approval was successful
    function approve(address spender, uint256 amount) public returns (bool success) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer WAPE tokens on behalf of an owner
    /// @param from The owner address
    /// @param to The recipient address
    /// @param amount The amount of WAPE tokens to transfer
    /// @return success Whether the transfer was successful
    function transferFrom(address from, address to, uint256 amount) public returns (bool success) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        require(to != address(0), "Cannot transfer to zero address");

        balanceOf[from] -= amount;
        allowance[from][msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice Fallback function to accept native APE directly
    receive() external payable {
        deposit();
    }
}

/// @notice Interface for ArbInfo contract to configure yield delegation
interface ArbInfo {
    function configureDelegateYield(address account) external;
}


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./IArbToken.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract FHE is IArbToken, ERC20, ERC20Burnable, AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant maxSupply = 1000000000 * 10 ** 18;

    event CCIPAdminChanged(address newAdmin);

    address private ccipAdmin;

    address public immutable l2Gateway;
    address public override l1Address;

    modifier onlyL2Gateway() {
        require(msg.sender == l2Gateway, "NOT_GATEWAY");
        _;
    }

    constructor(address _l2Gateway, address _l1TokenAddress) ERC20("MindNetwork FHE Token", "FHE") ERC20Permit("MindNetwork FHE Token") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        l2Gateway = _l2Gateway;
        l1Address = _l1TokenAddress;
        ccipAdmin = msg.sender;
    }

    function setCCIPAdmin(address newAdmin) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ccipAdmin = newAdmin;
        emit CCIPAdminChanged(ccipAdmin);
    }

    function getCCIPAdmin() external view returns (address) {
        return ccipAdmin;
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= maxSupply, "EXCEEDED_MAX_SUPPLY");
        _mint(to, amount);
    }

    /**
     * @notice should increase token supply by amount, and should only be callable by the L2Gateway.
     */
    function bridgeMint(address account, uint256 amount) external override onlyL2Gateway {
        require(totalSupply() + amount <= maxSupply, "EXCEEDED_MAX_SUPPLY");
        _mint(account, amount);
    }

    /**
     * @notice should decrease token supply by amount, and should only be callable by the L2Gateway.
     */
    function bridgeBurn(address account, uint256 amount) external override onlyL2Gateway {
        _burn(account, amount);
    }
}

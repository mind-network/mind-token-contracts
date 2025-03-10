// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract FHE is ERC20, ERC20Burnable, AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant maxSupply = 1000000000 * 10 ** 18;

    event CCIPAdminChanged(address newAdmin);

    address private ccipAdmin;

    constructor() ERC20("MindNetwork FHE Token", "FHE") ERC20Permit("MindNetwork FHE Token") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
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
}

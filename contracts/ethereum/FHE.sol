// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract FHE is ERC20, ERC20Permit {
    event CCIPAdminChanged(address newAdmin);

    address private ccipAdmin;
    address private pendingCCIPAdmin;

    constructor(address recipient) ERC20("MindNetwork FHE Token", "FHE") ERC20Permit("MindNetwork FHE Token") {
        _mint(recipient, 1000000000 * 10 ** decimals());
        ccipAdmin = msg.sender;
    }

    function transferCCIPAdmin(address newAdmin) external {
        require(msg.sender == ccipAdmin, "NOT_CURRENT_ADMIN");
        pendingCCIPAdmin = newAdmin;
    }

    function acceptCCIPAdmin() external {
        require(msg.sender == pendingCCIPAdmin, "NOT_PENDING_ADMIN");
        ccipAdmin = pendingCCIPAdmin;
        emit CCIPAdminChanged(ccipAdmin);
    }

    function getCCIPAdmin() external view returns (address) {
        return ccipAdmin;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./common/IGeneralError.sol";

contract Airdrop is IGeneralError, AccessControl {
    bytes32 private constant CONTRACT_ID = "Mind Airdrop";
    bytes32 public constant ADMIN_ROLE = "ADMIN_ROLE";
    bytes32 public constant BATCH_ROLE = "BATCH_ROLE";

    // The token to be airdropped
    IERC20 public immutable daoToken;

    // Merkle root of the airdrop data
    bytes32 public immutable merkleRoot;

    // Tracks addresses that have already claimed
    mapping(address => bool) public claimed;

    // Event for successful claim
    event Claimed(address indexed claimant, uint256 amount);

    constructor(IERC20 _token, bytes32 _merkleRoot, address _admin) {
        daoToken = _token;
        merkleRoot = _merkleRoot;
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function batchClaim(
        address[] calldata users,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs
    ) external onlyRole(BATCH_ROLE) {
        for (uint256 i; i < users.length; i++) {
            _claim(users[i], amounts[i], proofs[i]);
        }
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        _claim(msg.sender, amount, proof);
    }

    function _claim(address user, uint256 amount, bytes32[] calldata proof) private {
        // User can only claim once
        if (claimed[user]) {
            revert GeneralError(CONTRACT_ID, 410);
        }

        // Compute the leaf node from the sender’s address and amount
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));

        // Verify the proof
        bool isValidProof = MerkleProof.verify(proof, merkleRoot, leaf);
        if (!isValidProof) {
            revert GeneralError(CONTRACT_ID, 403);
        }

        // Mark as claimed
        claimed[user] = true;

        // Transfer tokens
        SafeERC20.safeTransfer(daoToken, user, amount);

        emit Claimed(user, amount);
    }

    function withdrawERC20(IERC20 tokenToWithdraw, address receiver, uint256 amount) external onlyRole(ADMIN_ROLE) {
        tokenToWithdraw.transfer(receiver, amount);
    }
}

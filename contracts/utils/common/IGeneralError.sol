// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IGeneralError {
    /**
     * @notice Custom error used for general failures within the contract.
     * @dev Includes the contract ID and an error code to identify specific issues.
     * @param contractID The identifier of the contract emitting the error.
     * @param errorCode A numeric error code representing the specific error type.
     */
    error GeneralError(bytes32 contractID, uint16 errorCode);
}

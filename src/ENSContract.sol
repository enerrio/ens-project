// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/// @title ENS Project
/// @author Aaron Marquez
/// @notice This contract registers and stores a human-readable name to an ETH address. A miniature version of ENS
contract ENSContract {
    /// @notice When a name is already taken
    error NameUnavailable();

    /// @notice When someone tries to modify a name they don't own
    error NameAccessDenied();

    mapping(string => address) public ensRegistry;
    uint private registrySize;

    event AddressRegistered(address indexed owner, string name);
    event AddressReleased(address indexed owner, string name);

    /// @notice Register a human-readable name to the caller's address
    /// @param name human-readable name to be mapped to caller's address
    /// @dev There's an upper bound for registrySize if registry gets larger than uint256
    function register(string calldata name) external returns (bool) {
        if (ensRegistry[name] != address(0)) {
            revert NameUnavailable();
        }
        ensRegistry[name] = msg.sender;
        registrySize += 1;
        emit AddressRegistered(msg.sender, name);
        return true;
    }

    /// @notice Release owner's human-readable name
    /// @param name human-readable name that maps to an address
    /// @dev caller can only release their own address
    function release(string calldata name) external returns (bool) {
        if (ensRegistry[name] != msg.sender) {
            revert NameAccessDenied();
        }
        delete ensRegistry[name];
        emit AddressReleased(msg.sender, name);
        return true;
    }

    /// @notice Returns the address registered to a given name
    /// @param name A human-readable name
    /// @return The address of the given name
    function retrieve(string calldata name) external view returns (address) {
        return ensRegistry[name];
    }

    /// @notice Returns the total number of registered addresses
    /// @return The total number of items in registry
    /// @dev Will return incorrect value if registry size gets larger than uint256
    function retrieveRegistrySize() external view returns (uint) {
        return registrySize;
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/ENSContract.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract ContractTest is Test {

    ENSContract internal ensContract;
    string internal constant SAMPLE_NAME = "shakespeare.eth"; 

    event AddressRegistered(address indexed owner, string name);
    event AddressReleased(address indexed owner, string name);

    function setUp() public {
        ensContract = new ENSContract();
    }

    /// TEST REGISTER FUNCTIONS ///

    /// @notice Try to register a single constant name
    function testRegisterOneName() public {
        bool success = ensContract.register(SAMPLE_NAME);
        assertTrue(success);
    }

    /// @notice Try to register multiple fuzzed names
    function testRegisterName(string memory sampleName) public {
        bool success = ensContract.register(sampleName);
        assertTrue(success);
    }

    /// @notice Try to register a name that is already taken
    function testRegisterTakenName() public {
        ensContract.register(SAMPLE_NAME);
        vm.expectRevert(ENSContract.NameUnavailable.selector);
        ensContract.register(SAMPLE_NAME);
    }

    /// TEST EMITS ///
    
    /// @notice Check that address registered event is emitted
    function testExpectRegisterEmit() public {
        vm.expectEmit(true, false, false, true);
        emit AddressRegistered(address(this), SAMPLE_NAME);
        ensContract.register(SAMPLE_NAME);
    }

    /// @notice Check that address release event is emitted
    function testExpectReleaseEmit() public {
        ensContract.register(SAMPLE_NAME);
        vm.expectEmit(true, false, false, true);
        emit AddressReleased(address(this), SAMPLE_NAME);
        ensContract.release(SAMPLE_NAME);
    }

    /// TEST RETRIEVALS ///

    /// @notice Try to retrieve a single constant name
    function testRetrieveOneName() public {
        ensContract.register(SAMPLE_NAME);
        address owner = ensContract.retrieve(SAMPLE_NAME);
        assertEq(owner, address(this));
    }

    /// @notice Try to get the total size of registry
    function testGetRegistrySize() public {
        uint size = ensContract.retrieveRegistrySize();
        assertEq(size, 0);
    }

    /// @notice Try to get the total size of registry after multiple register calls
    function testGetRegistrySizeFuzzed(uint8 numRegisters) public {
        for (uint8 i=0; i < numRegisters; i++) {
            ensContract.register(Strings.toString(i));
        }
        uint size = ensContract.retrieveRegistrySize();
        assertEq(size, numRegisters);
    }

    /// TEST RELEASE FUNCTIONS ///

    /// @notice A name can be released only by the owner
    function testReleaseAsOwner() external {
        ensContract.register(SAMPLE_NAME);
        bool success = ensContract.release(SAMPLE_NAME);
        assertTrue(success);
    }

    /// @notice Revert occurs when non-owner tries to release
    function testReleaseAsNotOwner() external {
        ensContract.register(SAMPLE_NAME);
        vm.expectRevert(ENSContract.NameAccessDenied.selector);
        vm.prank(address(0));
        ensContract.release(SAMPLE_NAME);
    }
}

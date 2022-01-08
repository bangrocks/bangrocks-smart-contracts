// contracts/BANGProxy.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract BANGProxy is BeaconProxy {
  // Pass empty data so contract verification is consistent
  constructor(address beacon) BeaconProxy(beacon, "") {}

  // Expose implementation to contract proxy readers
  function implementation() public view returns (address) {
    return _implementation();
  }
}

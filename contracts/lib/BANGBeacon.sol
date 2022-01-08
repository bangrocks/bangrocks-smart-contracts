// contracts/BANGBeacon.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "./interfaces/IBANG.sol";
import "./BANGProxy.sol";
import "./BANGLib.sol";

contract BANGBeacon is UpgradeableBeacon {
  address[] private _deploymentAddresses;
  IBANG private bang;

  constructor(address _implementation, address _bang) UpgradeableBeacon(_implementation) {
    bang = IBANG(_bang);
  }

  function totalDeployments() public view returns (uint256) {
    return _deploymentAddresses.length;
  }

  function getDeploymentByIndex(uint256 index) public view returns (address) {
    require(index < totalDeployments(), "BANGBeacon: global index out of bounds");
    return _deploymentAddresses[index];
  }

  function create() external returns (address) {
    bang.checkRole(BANGLib.ROLE_BANG, _msgSender());
    address bangProxy = address(new BANGProxy(address(this)));
    _deploymentAddresses.push(bangProxy);
    return bangProxy;
  }
}

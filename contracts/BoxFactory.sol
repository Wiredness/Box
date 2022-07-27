// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "./Box.sol";

// https://forum.openzeppelin.com/t/deploying-upgradeable-proxies-and-proxy-admin-from-factory-contract/12132/13
// Could make the factory upgradeable via UUPS which will allow us to have a nice createBox API and allow us to upgrade the contract initialiser if we need in future...
abstract contract InstrumentFactory {
    address immutable boxBeacon;

    event BoxDeployed(address boxAddress);

    constructor() {
        UpgradeableBeacon _boxBeacon = new UpgradeableBeacon(address(new Box()));
        _boxBeacon.transferOwnership(msg.sender);
        boxBeacon = address(_boxBeacon);
    }   

    // this method the initialiser isn't upgradable...
    function createBox(uint256 value) external returns (address) {
        BeaconProxy proxy = new BeaconProxy(
            boxBeacon,
            abi.encodeWithSelector(Box.initialise.selector, value)
        );

        emit BoxDeployed(address(proxy));
        return address(proxy);
    }

    // this method the initialiser is upgradable but the API is going to be trash...
    // function createBox(bytes calldata data) external returns (address) {        
    //     BeaconProxy proxy = new BeaconProxy(
    //         instrumentBeacon,
    //         data
    //     );
        
    //     emit InstrumentDeployed(address(proxy));
    //     return address(proxy);
    // }
}
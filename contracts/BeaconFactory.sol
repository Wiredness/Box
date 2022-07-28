// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Box.sol";

// https://forum.openzeppelin.com/t/deploying-upgradeable-proxies-and-proxy-admin-from-factory-contract/12132/13
contract BeaconFactory is UpgradeableBeacon {    
    event ProxyDeployed(BeaconProxy proxy);

    constructor(address implementation) UpgradeableBeacon(implementation) { }   
     
    function createProxy(bytes calldata data) external returns (BeaconProxy) {        
        BeaconProxy proxy = new BeaconProxy(
            address(this),
            data
        );
    
        emit ProxyDeployed(proxy);
        return proxy;
    }
}
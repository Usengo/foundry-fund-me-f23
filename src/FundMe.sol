// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe_NotOwner();
        _;
    }

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, 
            "You need to spend more ETH!"
        );
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
            
        }
    

    function cheaperWithdraw() public onlyOwner {
       uint256 fundersLength = s_funders.length; 
       for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
       }
       s_funders = new address[](0);

       (bool callSuccess,) =
        payable(msg.sender).call
        {value: address(this).balance}
        ("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0;
         funderIndex < s_funders.length;
          funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    
    function getVersion() public pure returns (uint256) {
        return 4;  // Example version number
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund(); 
    }

    function getAddressToAmountFunded(
      address fundingAddress
     ) external view returns (uint256){
        return s_addressToAmountFunded[fundingAddress];
     }

     function getFunder(uint256 index) external view returns (address) {
     return s_funders[index];
    
    }

    // function getOwner() external view returns(address) {
    //     return i_owner;
    //}

}

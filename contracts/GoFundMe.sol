// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./PriceConverterLibrary.sol";

error GoFundMe__NotOwner(string message);
error GoFundMe__AmountNotEnough(string message);
error GoFundMe__WithdrawalFailed(string message);

/**
 * @title A contract for crowd founding
 * @author Okwuosa Chijioke
 * @notice This is a demo for funding and withdrawing funds
 * @dev This implements price feed as a library
 */
contract GoFundMe {
  using PriceConverter for uint256;
  uint256 public constant MINIMUM_USD = 5 * 1e18; // we mutiply by 18 zeros so the unit will be same as etherium
  address[] public s_funders;
  mapping(address => uint256) public s_addressToAmountFunded;
  address public immutable i_owner; // owner of the contract
  AggregatorV3Interface public s_priceFeed;

  // a modifier is a keyword we can add to a function declaration to modifier the behaviour of that function
  modifier onlyOwner() {
    if (msg.sender != i_owner)
      revert GoFundMe__NotOwner({message: "Sender is not contract owner"});
    _; /* this line means do the rest of the code in the function that calls this
       modifier after running the code in this modifier, if this _; comes first in the modifier
       it means do every thing in the calling function first before running the content of the modifier*/
  }

  constructor(address s_priceFeedAddress) {
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
  }

  receive() external payable {
    fund();
  }

  fallback() external payable {
    fund();
  }  

  /**
   * @notice This funtion handles the funding of ether
   * if a function has params you can document them with the params keyword  
   */
  function fund() public payable {  
    if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD)
      revert GoFundMe__AmountNotEnough({message: "Amount sent is not enough"});

    s_funders.push(msg.sender);
    s_addressToAmountFunded[msg.sender] += msg.value;
  }

  function withdraw() public onlyOwner {
    for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
      address funder = s_funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    //reset s_funders array to new array with zero item
    s_funders = new address[](0);   
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    if (!callSuccess)
      revert GoFundMe__WithdrawalFailed({message: "Transfer failed"});
  }

  function cheaperWithdraw() public onlyOwner {
    /* reading from storage once is better that reading from it continously in the loop.
      reading and writing to  storage comsumes much gas, so it is better to loop 
      from memory than storage    
    */
    address[] memory funders = s_funders;
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    //reset s_funders array to new array with zero item
    s_funders = new address[](0);   
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    if (!callSuccess)
      revert GoFundMe__WithdrawalFailed({message: "Transfer failed"});
  }
}

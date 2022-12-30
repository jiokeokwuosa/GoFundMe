// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./PriceConverterLibrary.sol";

/*
 in this contract we want to
  1. Get funds from users
  2. Withdraw funds
  3.Set a minimum funding value in USD

  Each transaction contains information like nonce(transaction count for the account), gas price,
  gas limit, to(address that the transaction is sent to), value(amount of wei to send), data(what to send
  to `to` address), vrs(crypotographic magic) component of the transaction signature.

  Note: you can import console.log package and work with it in your contract
*/
// you can have different custom errors for different cases
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
  /* this line above will make the functions of price converter library imported in this contract 
    accessible via uint256 eg msg.value.getConversionRate(), remember that msg.value has type uint256
    if the library function takes parameters, the uint256 value is regarded as the the first paramter
    eg msg.value in the example msg.value.getConversionRate(), the other parameters of the function
    can then be passed in the parenthesis of the function

    constants and immutable are used to declare variables that won't change and it is more gas efficient,
    because they are stored into the bytecode and not on the storage slot, they are easier to be read.
    constants should be declared with capital letters and underscore is used to join mutiple words
    use immutable for variables that will only recieve value once but in a different place from the line
    where it was declared eg variables that recieve there values in a contructor, immutable variables names
    can be preceded with i_ eg i_owner.
    using less require statement can  be gas efficient because the second argument of the require statement
    which is the string to be displayed when error occurs will need to be stored and thus will consume more gas
    rather work with custom errors and if statements which is more gas efficient.
    storage variables should be preceded with s_
    reading and writing to storage consumes much gas
    */

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

  /* In order to send etherium you have to add payable keyword to the processing function
   * msg.value returns the value of wei a person is sending
   * msg.sender returns the address of whoever calls the function
   */

  /**
   * @notice This funtion handles the funding of ether
   * if a function has params you can document them with the params keyword  
   */
  function fund() public payable {
    /* to validate the amount of ether the user is sending
          the require function checks whether the condition is passed, if condition fails
          it will display the message in the second argument, revert the previous action done
          in that function call (if any) and return the remaining gas fee (so the gas fee used to do
          any action before the line of code with the require statment will be lost) eg
           require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,"Amount sent is not enough");
           but custom errors are more gas efficient than require
        */

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
    /*withdraw the actual funds, we can do that through transfer, send or call function,
        msg.sender is of type address, while payable(msg.sender) is of type payable address,
        address(this).balance returns the balance of the contract. The transfer and send method
        consumes 2300 gas and fails if the transaction requires more than 2300 gas
        */
    // // using transfer, it automatically reverts if the transfer fails
    // payable(msg.sender).transfer(address(this).balance);
    // /*using send, it doen't revert if transfer fails, rather it returns a boolean value false,
    //  so we might need to use require to revert it ourselves if it fails*/
    // bool sendSuccess = payable(msg.sender).send(address(this).balance);
    // require(sendSuccess,"Transfer failed");
    // // using call, returns 2 values, first one indicates whether it was successful and the other is the returned data(bytes memory dataReturned)
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

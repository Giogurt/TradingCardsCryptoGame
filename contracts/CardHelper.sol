// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./TradingCards.sol";
import "./utils/SafeMath.sol";

contract CardHelper is TradingCards {

  using SafeMath16 for uint16;

  uint nameChangeFee = 0.001 ether;
  uint upgradeCardStatFee = 0.005 ether;
  uint boosterPackFee = 0.004 ether;
  uint8 boosterPackQuantity = 5;

  uint16 statUpgradeAmount = 10;

  modifier onlyOwnerOf(uint _cardId) {
    require(msg.sender == cardToOwner[_cardId]);
    _;
  }

  function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
  }

  function setNameChangeFee(uint _fee) external onlyOwner {
    nameChangeFee = _fee;
  }

  function setUpgradeCardStatFee(uint _fee) external onlyOwner {
    upgradeCardStatFee = _fee;
  }

  function setBoosterPackFee(uint _fee) external onlyOwner {
    boosterPackFee = _fee;
  }

  function setBoosterPackQuantity(uint8 _quantity) external onlyOwner {
    boosterPackQuantity = _quantity;
  }


  function setStatsDigits(uint _digits) external onlyOwner {
    statsDigits = _digits;
  }

  function setClassDigits(uint _digits) external onlyOwner {
    classDigits = _digits;
  }

  function setSkillDigits(uint _digits) external onlyOwner {
    skillDigits = _digits;
  }

  function setStatUpgradeAmount(uint16 amount) external onlyOwner {
    statUpgradeAmount = amount;
  }

  function _generateBoosterPack(address _player) internal {
      for(uint i = 0; i < boosterPackQuantity; i++) {
          _createRandomCard(_player);
      }
  }

  function acquireBoosterPack() payable external {
    require(msg.value == boosterPackFee);
    _generateBoosterPack(msg.sender);
  }

  function _upgradeCardStats(uint _cardId) internal {
      cards[_cardId].health = cards[_cardId].health.add(statUpgradeAmount);
      cards[_cardId].attack = cards[_cardId].attack.add(statUpgradeAmount);
      cards[_cardId].defense = cards[_cardId].defense.add(statUpgradeAmount);
  }

  /**
  * @param stat - 0 - health, 1 - attack, 2 - defense
  * @dev upgrades an especific card stat
  */
  function upgradeCardStat(uint _cardId, uint8 stat) payable external onlyOwnerOf(_cardId) returns(uint16) {
    require(msg.value == upgradeCardStatFee);
    require(stat == 0 || stat == 1 || stat == 2);
    if(stat == 0) {
      cards[_cardId].health = cards[_cardId].health.add(10);
      return cards[_cardId].health;
    } else if (stat == 1) {
      cards[_cardId].attack = cards[_cardId].attack.add(10);
      return cards[_cardId].attack;
    } else {
      cards[_cardId].defense = cards[_cardId].defense.add(10);
      return cards[_cardId].defense;
    } 
  }

  function changeName(uint _cardId, string calldata _newName) payable external onlyOwnerOf(_cardId) {
    require(msg.value == nameChangeFee);
    cards[_cardId].name = _newName;
  }

  function getCardsByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerCardCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < cards.length; i++) {
      if (cardToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}

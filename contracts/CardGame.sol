// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CardHelper.sol";

contract CardGame is CardHelper {

  function attack(uint _cardId, uint _enemyCardId) external onlyOwnerOf(_cardId) {
    Card storage myCard = cards[_cardId];
    Card storage enemyCard = cards[_enemyCardId];

    if(int16(enemyCard.health) - (int16(myCard.attack) - int16(enemyCard.defense)) <= int16(myCard.health) - (int16(enemyCard.attack) - int16(myCard.defense))) {
      _upgradeCardStats(_cardId);
    } else {
      _upgradeCardStats(_enemyCardId);
    }
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CardHelper.sol";

/**
* @title CardGame
* @dev Logic for card to interact between one another.
*/
contract CardGame is CardHelper {

  /**
  * @param _cardId Id of the card that initiated the attack
  * @param _enemyCardId Id of the card that will be attacked
  * @dev Attack logic between cards.
  */
  function attack(uint _cardId, uint _enemyCardId) external onlyOwnerOf(_cardId) {
    Card storage myCard = cards[_cardId];
    Card storage enemyCard = cards[_enemyCardId];

    // The winner is determined by the card with the most hp remaining after applying 
    // the logic - THIS_CARD_HEALTH - (OTHER_CARD_ATTACK - THIS_CARD_HEALTH)
    if(int16(enemyCard.health) - (int16(myCard.attack) - int16(enemyCard.defense)) <= int16(myCard.health) - (int16(enemyCard.attack) - int16(myCard.defense))) {
      _upgradeCardStats(_cardId);
    } else {
      _upgradeCardStats(_enemyCardId);
    }
  }
}

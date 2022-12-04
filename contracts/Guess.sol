// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract GuessNumber {
    event Stake (
        address indexed from,
        uint value
    );
    mapping(address => uint) balance;
    uint randomNumber;
    bool isGameActive = false;
    bool wonGame;
    uint amountToBeWon;
    uint initialStake;
    uint triesLeft; // this will be kept in memory
    uint winMultiplier; // 10x, 20x, 30x

    function startGame(uint _stake, uint _limit, uint _winMultiplier) private {
        // make game active
        isGameActive = true;
        amountToBeWon = _stake * _winMultiplier; // TODO ensure _stake is converted to uint
        triesLeft = _limit;
        initialStake = _stake;
        randomNumber = generateRandomNumber(101);
    }

   function isGuessCorrect(uint guess) internal view returns(bool) {
        return guess == randomNumber;
    }

    function generateRandomNumber(uint range) internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % range;
    }

    function initializeGame(uint _stake) external payable {
        startGame(_stake, 3, 10); // will modify this to come from the client
        emit Stake(msg.sender, msg.value);
    }

    function guessNumber(uint _guess) external {
        if (!isGuessCorrect(_guess) && triesLeft > 0) {
            triesLeft--;
        } else if(triesLeft == 0 && !isGuessCorrect(_guess)) {
            gameOver();
        } else if(isGuessCorrect(_guess)) {
            wonGame = true;
            gameOver();
        }
    }

    function isBalanceSufficient(uint256 amount) private view returns (bool) {
        return amount > balance[msg.sender] ? false : true;
    } 

    function gameOver() public {
        isGameActive = false;
    }

    function getGameInfo() view public returns(uint, bool, bool) {
        return (triesLeft, isGameActive, wonGame);
    }
    // function login(credentials) public {} 
}
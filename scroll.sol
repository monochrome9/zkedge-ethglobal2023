// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract TicTacToe {
    address public player1;
    address public player2;
    address public winner;
    uint public stake;
    bool public gameEnded;
    uint8[9] public board;

    constructor() {
        player1 = address(0);
        player2 = address(0);
        stake = 0;
        gameEnded = false;
        board = [uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0), uint8(0)];
    }

    modifier onlyPlayers() {
        require(msg.sender == player1 || msg.sender == player2, "You are not a player in this game.");
        _;
    }

    function currentPlayer() public view returns (address) {
        return (winner == address(0)) ? ((board[0] == 0) ? player1 : player2) : address(0);
    }

    function joinGame() public payable {
        require(player2 == address(0), "The game is already full.");
        require(!gameEnded, "The game has ended. You can start a new game.");
        require(msg.value == 0.001 ether, "Please send 0.001 ETH to join the game.");
        if (player1 == address(0)) {
            player1 = msg.sender;
        } else {
            player2 = msg.sender;
        }
        stake = stake + msg.value;
    }

    function makeMove(uint8 move) public onlyPlayers {
        require(move >= 1 && move <= 9, "Invalid move. Choose a number from 1 to 9 in base-12.");
        require(board[move - 1] == 0, "Cell is already occupied.");
        require(msg.sender == currentPlayer(), "It's not your turn.");

        if (msg.sender == player1) {
            board[move - 1] = 1;
        } else {
            board[move - 1] = 2;
        }

        if (checkWinner()) {
            winner = msg.sender;
            gameEnded = true;
        } else if (boardIsFull()) {
            gameEnded = true;
        }
    }

     function checkWinner() internal view returns (bool) {
        uint8[3][8] memory winningCombinations = [
        [uint8(0), uint8(1), uint8(2)],
        [uint8(3), uint8(4), uint8(5)],
        [uint8(6), uint8(7), uint8(8)],
        [uint8(0), uint8(3), uint8(6)],
        [uint8(1), uint8(4), uint8(7)],
        [uint8(2), uint8(5), uint8(8)],
        [uint8(0), uint8(4), uint8(8)],
        [uint8(2), uint8(4), uint8(6)]
    ];

    for (uint i = 0; i < 8; i++) {
        uint8[3] memory combo = winningCombinations[i];
        if (board[combo[0]] != 0 && board[combo[0]] == board[combo[1]] && board[combo[1]] == board[combo[2]]) {
            return true;
        }
    }

    return false;
}

    function boardIsFull() internal view returns (bool) {
        for (uint8 i = 0; i < 9; i++) {
            if (board[i] == 0) {
                return false;
            }
        }
        return true;
    }

    function withdraw() public {
        require(!gameEnded, "The game has ended. You can start a new game.");
        require(winner == msg.sender, "You are not the winner.");
        require(address(this).balance > 0, "The contract balance is empty.");
        uint amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function startNewGame() public {
        require(gameEnded, "The previous game is still ongoing.");
        player1 = address(0);
        player2 = address(0);
        stake = 0;
        gameEnded = false;
        winner = address(0);

        for (uint8 i = 0; i < 9; i++) {
            board[i] = 0;
        }
    }
}
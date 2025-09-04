// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// Deklarasi versi kompiler solidity menggunakan keyword pragma

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// Import kontrak ERC721URIStorage dari OpenZeppelin untuk mengelola token NFT

contract RockPaperScissors is ERC721URIStorage {
    // deklarasi kontrak utama bernama RockPaperScissors yang mewarisi ERC721URIStorage
    enum Move { // Enum secara singkat adalah tipe data pilihan, diambil dari kata enumeration
        None, // 0
        Rock, // 1
        Paper, // 2
        Scissors // 3
    } // Nilai mengikuti urutan deklarasi yang dimulai dari 0

    enum GameStatus { // Enum atau pilihan untuk status permainan
        Waiting,
        Ongoing,
        Finished
    }

    struct Game { // Struct adalah tipe data kompleks yang dapat menyimpan beberapa tipe data
        address player1; // address pemain pertama
        address player2; // address pemain kedua
        Move move1; // Move pemain pertama apakah Rock, Paper, atau Scissors sesuai enum Move yang telah ditentukan
        Move move2; // Move pemain kedua
        GameStatus status; // Enum GameStatus untuk status permainan
        address winner; // address pemenang permainan
    }

    address public owner; // address pemilik kontrak dideklarasikan dengan nama owner
    uint256 public gameCounter; // counter untuk jumlah game yang telah dibuat dengan tipe data uint256
    mapping(uint256 => Game) public games;
    // mapping adalah struktur data yang menyimpan pasangan key-value, dalam hal ini key adalah game

    uint256 private _tokenIds; // 🔥 simple counter variable

    // Events
    event GameCreated(uint256 indexed gameId, address indexed creator); // Event untuk menandai pembuatan game baru yang memiliki parameter gameId dan creator
    // begitupun seterusnya
    event GameJoined(uint256 indexed gameId, address indexed joiner);
    event MoveSubmitted(uint256 indexed gameId, address indexed player);
    event GameFinished(uint256 indexed gameId, address winner);
    event NFTRedeemed(address indexed player, uint256 tokenId, uint256 gameId);
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    // Error Handling
    // hanya sebatas dideklarasikan sebagai tipe data saja, tanpa impelementasi
    // real implementasi ada pada fungsi yang menggunakan pengkondisian if pada error handling nya
    error OnlyOwner();
    error InvalidGame(uint256 gameId);
    error InvalidMove();
    error NotYourTurn();
    error GameFull(uint256 gameId);
    error GameNotOngoing(uint256 gameId);
    error NotWinner(uint256 gameId);

    modifier onlyOwner() { // modifier untuk membatasi akses hanya untuk owner kontrak
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    constructor() ERC721("RPS Victory NFT", "RPSNFT") { // konstruktor kontrak yang memanggil konstruktor ERC721 dengan nama token dan simbol token
        owner = msg.sender; // owner di set sebagai address yang mendeploy kontrak
    }

    // Fungsi untuk membuat game baru
    function createGame() external returns (uint256) { 
        gameCounter++; // increment gameCounter setiap kali fungsi dipanggil
        games[gameCounter] = Game({ 
        // games adalah mapping yang menyimpan data game berdasarkan gameCounter
        // kemdian Game struct diinisialisasi dengan nilai awal
            player1: msg.sender, // player1 di set sebagai address yang memanggil fungsi
            player2: address(0), // player2 di set sebagai address kosong
            move1: Move.None, // move1 di set sebagai enum Move dengan nilai default none
            move2: Move.None, // move2 juga sama
            status: GameStatus.Waiting, // status di set sebagai enum GameStatus dengan nilai default Waiting
            winner: address(0) // winner di set sebagai address kosong
        });
        emit GameCreated(gameCounter, msg.sender); // emit adalah keyword untuk memicu event, dalam hal ini memicu event GameCreated dengan parameternya
        return gameCounter; // mengembalikkan nilai gameCounter sebagai ID game yang baru dibuat
    }

    // fungsi untuk bergabung ke game yang sudah dibuat
    function joinGame(uint256 gameId) external { // menerima parameter gameId dengan tipe data uint256
        Game storage g = games[gameId]; // Game adalah struct yang dideklarasikan sebelumnya dengan storage untuk menyimpan data game berdasarkan gameId dam g adalah variabel lokal
        // pengkondisian error handling
        if (g.player1 == address(0)) revert InvalidGame(gameId);
        if (g.player2 != address(0)) revert GameFull(gameId);

        g.player2 = msg.sender; // player2 di set sebagai address yang memanggil fungsi joinGame
        g.status = GameStatus.Ongoing; // status di set sebagai enum GameStatus dengan nilai Ongoing
        emit GameJoined(gameId, msg.sender); // memicu event GameJoined dengan parameternya
    }

    function submitMove(uint256 gameId, Move move) external { // fungsi untuk mengirimkan move pemain dengan parameter gameId bertipe uint256 dan move bertipe enum Move
    
            // pengkondisian error handling
        if (move == Move.None) revert InvalidMove();
        Game storage g = games[gameId];
        if (g.status != GameStatus.Ongoing) revert GameNotOngoing(gameId);
        if (msg.sender == g.player1) {
            require(g.move1 == Move.None, "Already played");
            g.move1 = move;
        } else if (msg.sender == g.player2) {
            require(g.move2 == Move.None, "Already played");
            g.move2 = move;
        } else {
            revert NotYourTurn();
        }

        emit MoveSubmitted(gameId, msg.sender); // memicu event MoveSubmitted dengan parameternya

         // Jika kedua pemain sudah mengirimkan move, tentukan pemenangnya
        if (g.move1 != Move.None && g.move2 != Move.None) {
            _determineWinner(gameId);
        }
    }

    function _determineWinner(uint256 gameId) internal { // fungsi internal untuk menentukan pemenang berdasarkan gameId dengan tipe uint256
        Game storage g = games[gameId]; // mengambil data game berdasarkan gameId

            // Logika menentukan pemenang
        if (g.move1 == g.move2) {
            g.winner = address(0); // Draw
        } else if (
            (g.move1 == Move.Rock && g.move2 == Move.Scissors) ||
            (g.move1 == Move.Paper && g.move2 == Move.Rock) ||
            (g.move1 == Move.Scissors && g.move2 == Move.Paper)
        ) {
            g.winner = g.player1;
        } else {
            g.winner = g.player2;
        }

        g.status = GameStatus.Finished; // variabel lokal g di set statusnya menjadi Finished
        emit GameFinished(gameId, g.winner); // memicu event GameFinished dengan parameternya
    }

    // fungsi untuk menukarkan NFT kemenangan
    function redeemVictoryNFT(
        uint256 gameId,
        string memory tokenURI // parameter bertipe string disimpan di memory dan tokenURI adalah nama variabelnya
    ) external returns (uint256) {
        Game memory g = games[gameId]; // mengambil data game berdasarkan gameId dan disimpan di variabel lokal g dengan tipe memory
            // pengkondisian error handling
        if (g.status != GameStatus.Finished) revert GameNotOngoing(gameId);
        if (g.winner != msg.sender) revert NotWinner(gameId);

        // Mint NFT to the winner
        _tokenIds++; // increment counter NFT
        uint256 newItemId = _tokenIds; // menyimpan nilai counter NFT ke variabel lokal newItemId dengan tipe uint256 dan _tokenIds adalah nama variabel counter NFT

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit NFTRedeemed(msg.sender, newItemId, gameId);
        return newItemId;
    }

        // fungsi untuk mengambil data game berdasarkan gameId
    function getGame(uint256 gameId) external view returns (Game memory) {
        return games[gameId];
    }

    // Fungsi untuk mentransfer kepemilikan kontrak
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address old = owner;
        owner = newOwner;
        emit OwnershipTransferred(old, newOwner);
    }
}

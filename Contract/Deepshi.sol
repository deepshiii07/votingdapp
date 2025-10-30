// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DecentralizedVoting {
    // --- STRUCTS ---
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    // --- STATE VARIABLES ---
    address public admin;
    uint public candidatesCount;
    bool public votingOpen;

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;

    // --- EVENTS ---
    event CandidateAdded(uint id, string name);
    event VoteCasted(address voter, uint candidateId);
    event VotingOpened();
    event VotingClosed();

    // --- CONSTRUCTOR ---
    constructor() {
        admin = msg.sender; // contract deployer = admin
    }

    // --- MODIFIERS ---
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    modifier whenVotingOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    // --- ADMIN FUNCTIONS ---
    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    function openVoting() public onlyAdmin {
        votingOpen = true;
        emit VotingOpened();
    }

    function closeVoting() public onlyAdmin {
        votingOpen = false;
        emit VotingClosed();
    }

    // --- VOTER FUNCTION ---
    function vote(uint _candidateId) public whenVotingOpen {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;

        emit VoteCasted(msg.sender, _candidateId);
    }

    // --- VIEW FUNCTIONS ---
    function getCandidate(uint _candidateId) public view returns (string memory name, uint votes) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        Candidate memory c = candidates[_candidateId];
        return (c.name, c.voteCount);
    }

    function getWinner() public view returns (string memory winnerName, uint winnerVotes) {
        uint maxVotes = 0;
        uint winnerId = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }

        if (winnerId == 0) {
            return ("No votes yet", 0);
        }

        return (candidates[winnerId].name, maxVotes);
    }
}

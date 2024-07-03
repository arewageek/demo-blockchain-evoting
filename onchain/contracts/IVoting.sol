// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface IVoting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
        bool isValid;
    }

    struct Voter {
        address account;
        bool voted;
        bool isValid;
    }

    struct PendingVoter {
        address account;
        uint applicationNumber;
        ApplicationStatus status;
    }

    struct Ballot {
        uint ballotId;
        Candidate[] votes;
    }

    struct Team {
        address account;
        Roles role;
    }

    struct Office {
        uint officeId;
        Candidate[] candidates;
        bool isRequired;
    }

    // restructure contract to accomodate multiple positions and allow voters pass in all candidates for all positons in a single request

    enum Status {
        VALID,
        SUSPENDED,
        ALL
    }
    
    enum Roles {
        BOT,
        CHAIRPERSON,
        OBSERVER
    }

    enum ApplicationStatus {
        FAILED,
        PENDING
    }

    event VotersAccredited(address[] voters);
    event VotersSuspended(address[] voters);
    event CandidatesRegistered(string[] candidates);
    event CandidatesSuspended(uint[] candidates);
    event VoteCasted(address voter);

    function accreditVoters(address[] memory _voters) external;
    function suspendVoters(address[] memory _voters) external;

    function registerCandidates(string[] memory candidates) external;
    function suspendCandidates(uint[] memory candidateId) external;

    function votersCount(Status votersType) external returns (uint);
    function candidatesCount(Status candidateType) external returns (uint);
    function verifyVoterAccreditation(address voter) external returns(bool);
    function verifyVoterVotingState(address account) external returns (bool);
    
    // function readAllBallots() external returns (ballots[]);

    function castVote(uint[] memory candidatesIndex) external;

    function candidateScore(uint candiadateIndex) external returns (uint);
    // function electionResult() external returns(Candidate[] memory);

    function getAllCandidates() external returns (Office[] memory); //returning an array of offices make it easier for my app to read and group the data

    function voterApplication(uint voterRegId) external;
    function pendingVoterApplications() external returns (PendingVoter[] memory);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import { IVoting } from "./IVoting.sol";

contract Voting is IVoting {
    Candidate internal candidate;
    Voter internal voter;
    Team internal teamStruct;
    Ballot internal ballot;

    Ballot[] internal ballots;
    PendingVoter[] internal pendingVoters;
    Candidate[] candidatesData;
    Office[] offices;

    uint private _candidatesCount;
    uint private _votersCount;
    uint public votesCount;

    mapping(uint => Candidate) internal candidates;
    mapping(address => Team) internal team;
    mapping(address => Voter) public voters;
    mapping(address => PendingVoter) private pendingVoter;

    modifier onlyChairperson () {
        require(team[msg.sender].role == Roles.CHAIRPERSON, "Unauthorized: Chairperson only!");
        _;
    }

    modifier onlyVoter () {
        require(voters[msg.sender].isValid, "Unauthorized: Valid voters only!");
        _;
    }

    modifier onlyBot () {
        require(team[msg.sender].role == Roles.BOT || team[msg.sender].role == Roles.CHAIRPERSON, "Unauthorized: Deployer only");
        _;
    }

    modifier validCandidate(uint candidateIndex){
        bool candidateExist = false;
        bool candidateIsValid = false;

        for(uint index; index <= _candidatesCount; index ++){
            if(candidateIndex <= _candidatesCount ){
                candidateExist = true;

                if(candidates[candidateIndex].isValid){
                    candidateIsValid = true;
                }
            }

        }
        require(candidateExist, "Candidate not found");
        
        require(candidateIsValid, "Candidate not eligible");

        _;
    }

    constructor(address chairperson) IVoting(){
        team[chairperson].role = Roles.CHAIRPERSON;
    }

    function accreditVoters(address[] memory _voters) external onlyChairperson(){
        uint numVotersToBeAccredited = _voters.length;
        
        for(uint count; count < numVotersToBeAccredited; count ++){
            voters[_voters[count]] = Voter(
                _voters[count], false, true
            );
        }

        emit VotersAccredited(_voters);
    }

    function suspendVoters(address[] memory _voters) external onlyChairperson(){ 
        for (uint count; count < _voters.length; count ++){
            voters[_voters[count]].isValid = false;
        }

        emit VotersSuspended(_voters);
    }
    
    function registerCandidates(string[] memory _candidates) external onlyChairperson(){        
        for(uint count; count < _candidates.length; count ++){
            candidates[count] = Candidate(
                _candidatesCount + 1, _candidates[count], 0, true
            );
        }
        
        emit CandidatesRegistered(_candidates);
    }

    function suspendCandidates(uint[] memory _candidates) external onlyChairperson(){ 
        for (uint count; count < _candidates.length; count ++){
            candidates[_candidates[count]].isValid = false;
        }

        emit CandidatesSuspended(_candidates);
    }


    function votersCount(Status votersType) external view returns (uint){
        if(votersType == Status.ALL){
            return _votersCount;
        }
        return _votersCount;
        
    }

    function candidatesCount(Status candidatesType) external view returns (uint){
        if(candidatesType == Status.ALL){
            return _candidatesCount;
        }

        return _candidatesCount;
    }

    function verifyVoterAccreditation(address account) external view returns (bool){
        return voters[account].isValid;
    }

    function verifyVoterVotingState(address account) external view returns (bool){
        return voters[account].voted;
    }

    function readAllBallots() external view onlyChairperson() returns (Ballot[] memory){
        return ballots;
    }

    function castVote(uint[] memory candidatesIndex) external onlyVoter{
        
        for(uint index; index < candidatesIndex.length; index ++){

            require(candidates[candidatesIndex[index]].isValid, "Candidate Not elible");

            candidates[candidatesIndex[index]].voteCount ++;
        }

        voters[msg.sender].voted = true;

        emit VoteCasted(msg.sender);
    }

    function candidateScore (uint candidateIndex) external view onlyBot() validCandidate(candidateIndex) returns(uint){
        return candidates[candidateIndex].voteCount;
    }

    function electionResult() external view returns (Candidate[] memory) {
        return candidatesData;
    }

    function voterApplication(uint voterRegId) external {
        pendingVoter[msg.sender] = PendingVoter(msg.sender, voterRegId, ApplicationStatus.PENDING);
    }

    function pendingVoterApplications() external view returns (PendingVoter[] memory){
        return pendingVoters;
    }

    function getAllCandidates() external view returns (Office[] memory){
        return offices;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";



contract MyGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, Ownable {
    
    // Voting delay in blocks. 1 block ~= 12 seconds
    uint256 public constant VOTING_DELAY = 1;

    // Voting period in blocks. 1 block ~= 12 seconds
    uint256 public constant VOTING_PERIOD = 25;

    // Quorum percentage
    uint256 public constant QUORUM_PERCENTAGE = 50;
    
    constructor(IVotes _token)
        Governor("MyGovernor")
        GovernorSettings(VOTING_DELAY, VOTING_PERIOD, 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(QUORUM_PERCENTAGE)
    {}


    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function proposalThreshold()
        public 
        view 
        override(Governor, GovernorSettings)
        onlyOwner
        returns (uint256)
    {
        return super.proposalThreshold();
    }
}
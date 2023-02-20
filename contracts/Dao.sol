//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO {
     event winner(uint256 _index, string proposal, Vote winningVote);

    struct Proposal {
        uint256 id;
        uint256 accept;
        uint256 reject;
        uint256 abstain;
        uint256 deadline;
        string title;
        string description;
        address creator;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => Vote)) public votes;
    uint256 public proposalCounter = 0;

    enum Vote {
        accept,
        reject,
        abstain
    }
     Proposal[] proposalList;

    IERC20 public token;

    constructor(address _token)  {
        token = IERC20(_token);
    }

    // function createProposal(string memory title, string memory _description) public {
    //     require(token.balanceOf(msg.sender) > 0, "You must hold a token to create a proposal");

    //     proposals[proposalCounter].title = title;
    //     proposals[proposalCounter].deadline = 	1676170597;
    //      proposals[proposalCounter].description = _description;
    //     proposals[proposalCounter].creator = msg.sender;
    //      proposals[proposalCounter].accept = 1;
    //     proposals[proposalCounter].reject = 0;
    //      proposals[proposalCounter].abstain = 0;
    //     proposals[proposalCounter].voted[msg.sender] = true;
    //     proposalCounter++;
    // }

    function createProposal(string memory _title, string memory _description) public {
        require(token.balanceOf(msg.sender) > 0, "You must hold a token to create a proposal");
        
        proposals[proposalCounter] = Proposal( proposalCounter, 0, 0, 0, block.timestamp + 1 days, _title, _description, msg.sender);
         votes[proposalCounter][msg.sender] = Vote.accept;
        proposals[proposalCounter].accept++;
        proposalList.push(proposals[proposalCounter]);
          
        proposalCounter ++;
    }

    function voteProposal(uint256 proposalId, Vote vote) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.deadline >= block.timestamp, "Voting has already closed for this proposal");
        require(token.balanceOf(msg.sender) > 0, "You must hold a token to vote");

        votes[proposalId][msg.sender] = vote;

        if (vote == Vote.accept) {
            proposal.accept++;
        } else if (vote == Vote.reject) {
            proposal.reject++;
        } else if (vote == Vote.abstain) {
            proposal.abstain++;
        }
    }

    function executeProposal(uint256 proposalId) public returns(uint256) {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.deadline <= block.timestamp, "Voting is still ongoing for this proposal");
        uint256 totalVotes = proposal.accept + proposal.reject + proposal.abstain;
        uint256 requiredVotes = token.totalSupply() / 2;
        require(proposal.accept > requiredVotes, "Proposal did not reach the minimum number of required votes");

        // Add logic for proposal execution here
         if (proposal.accept >= proposal.reject) {
            if (proposal.accept >= proposal.abstain) {
                emit winner(proposalId, proposal.title, Vote.accept);
            } else {
                emit winner(proposalId, proposal.title, Vote.abstain);
            }
        }
        else {
            if (proposal.reject >= proposal.abstain){
                emit winner(proposalId, proposal.title, Vote.reject);
            } else{
                emit winner(proposalId, proposal.title, Vote.abstain);
            }
        }

        return totalVotes;
    }

     function getProposals() public view returns (Proposal[] memory) {
        return proposalList;
    }

    function getProposalById(uint256 _id) public view returns (Proposal memory) {
        return proposals[_id];
    }
}

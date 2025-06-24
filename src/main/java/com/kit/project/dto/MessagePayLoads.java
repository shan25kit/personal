package com.kit.project.dto;

import java.util.List;

import lombok.Data;

public class MessagePayLoads {
	@Data
	public static class PlayerJoinRequest {
		private String nickname;
	}

	@Data
	public static class PlayerAction {
		private String nickname;
	}

	@Data
	public static class ScoreMessage {
		private String nickname;
		private int score;
	}

	@Data
	public static class TurnMessage {
		private String currentPlayer;
		private List<String> players;
		 public TurnMessage(String currentPlayer, List<String> players) {
		        this.currentPlayer = currentPlayer;
		        this.players = players;
		    }
	}
	
	@Data
	public static class GameOverMessage {
	    private String nickname;
	    private String message;

	    public GameOverMessage(String nickname, String message) {
	        this.nickname = nickname;
	        this.message = message;
	    }
	}
}
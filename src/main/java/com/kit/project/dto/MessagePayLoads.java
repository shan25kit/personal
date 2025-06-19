package com.kit.project.dto;

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
		 public TurnMessage(String currentPlayer) {
		        this.currentPlayer = currentPlayer;
		    }
	}
}

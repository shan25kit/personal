package com.kit.project.dto;

import java.util.List;

import lombok.Data;

public class MessagePayLoads {
	@Data
	public static class PlayerJoinRequest {
		private String nickname;

		public String getNickname() {
			return nickname;
		}

		public void setNickname(String nickname) {
			this.nickname = nickname;
		}
	}

	@Data
	public static class PlayerAction {
		private String nickname;

		public String getNickname() {
			return nickname;
		}

		public void setNickname(String nickname) {
			this.nickname = nickname;
		}
	}

	@Data
	public static class ScoreMessage {
		private String nickname;
		private int score;
		public String getNickname() {
			return nickname;
		}
		public void setNickname(String nickname) {
			this.nickname = nickname;
		}
		public int getScore() {
			return score;
		}
		public void setScore(int score) {
			this.score = score;
		}
	}

	@Data
	public static class TurnMessage {
		private String currentPlayer;
		private List<String> players;
		 public TurnMessage(String currentPlayer, List<String> players) {
		        this.setCurrentPlayer(currentPlayer);
		        this.setPlayers(players);
		    }
		public String getCurrentPlayer() {
			return currentPlayer;
		}
		public void setCurrentPlayer(String currentPlayer) {
			this.currentPlayer = currentPlayer;
		}
		public List<String> getPlayers() {
			return players;
		}
		public void setPlayers(List<String> players) {
			this.players = players;
		}
	}
	
	@Data
	public static class GameOverMessage {
	    private String nickname;
	    private String message;

	    public GameOverMessage(String nickname, String message) {
	        this.setNickname(nickname);
	        this.setMessage(message);
	    }

		public String getNickname() {
			return nickname;
		}

		public void setNickname(String nickname) {
			this.nickname = nickname;
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String message) {
			this.message = message;
		}
	}
}

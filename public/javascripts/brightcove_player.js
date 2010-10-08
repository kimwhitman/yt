var brightcovePlayer = {
  "params": {
    playerID:"107142267001",
    publishedID:"105925308001",
    bgcolor:"#ffffff",
    width:"600",
    height:"400",
    isVid:"true",
    videoId:"0",
  },
  startPlayer:function(){
    isPlayerAdded = true;
    playerName = "player1";
    var player = brightcove.createElement("object");
    player.id = playerName;
    var parameter;
    for (var i in this.params) {
      parameter = brightcove.createElement("param");
      parameter.name = i;
      parameter.value = this.params[i];
      player.appendChild(parameter);
    }

    var playerContainer = document.getElementById("x_video_player");

    brightcove.createExperience(player, playerContainer, true);
  }
}
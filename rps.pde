IntList plyrMov = new IntList(32);
IntList cmptMov = new IntList(32);
int plyrScore = 0, cmptScore = 0;
int[][] win = new int[][] { {0, 1, -1}, {-1, 0, 1}, {1, -1, 0} };
int moveDispDur = 1000;
int lastMoveTime = -moveDispDur - 199;
float iconSize = 120;
float[] iconX = new float[3];
float[] iconY = new float[3];
color plyrColour = #224466, cmptColour = #883322;

void setup() {
  size(600, 600);
  strokeWeight(10);
  ellipseMode(CORNER);
  fill(0, 0);
  iconX[0] = width * 1 / 6 - iconSize / 2;
  iconX[1] = width * 3 / 6 - iconSize / 2;
  iconX[2] = width * 5 / 6 - iconSize / 2;
  iconY[0] = iconY[1] = iconY[2] = height * 2 / 3;
}

void drawIcon(int idx, float x, float y, color c) {
  noFill();
  stroke(c);
  switch (idx) {
    case 0: // Rock
      ellipse(x, y, iconSize, iconSize);
      break;
    case 1: // Scissor
      line(x, y, x + iconSize, y + iconSize);
      line(x + iconSize, y, x, y + iconSize);
      break;
    case 2: // Paper
      rect(x, y, iconSize, iconSize);
      break;
  }
}

void draw() {
  background(232);

  if (millis() - lastMoveTime <= moveDispDur) {
    // Display the moves
    int plyrLastMove = plyrMov.get(plyrMov.size() - 1),
        cmptLastMove = cmptMov.get(cmptMov.size() - 1);
    drawIcon(plyrLastMove, iconSize / 2, height / 2 - iconSize, plyrColour);
    drawIcon(cmptLastMove, width - iconSize * 3 / 2, height / 2 - iconSize, cmptColour);
    noStroke();
    switch (win[plyrLastMove][cmptLastMove]) {
      case 1: fill(plyrColour, 32); rect(0, 0, width / 2, height); break;
      case -1: fill(cmptColour, 32); rect(width / 2, 0, width / 2, height); break;
    }
  }

  drawIcon(0, iconX[0], iconY[0], #000000);
  drawIcon(1, iconX[1], iconY[1], #000000);
  drawIcon(2, iconX[2], iconY[2], #000000);
  // Display the scores
  textSize(30);
  fill(plyrColour);
  text("Player: " + plyrScore, 60, 60);
  fill(cmptColour);
  text("Computer: " + cmptScore, height / 2 + 60, 60);
}

boolean pointInRect(float px, float py, float rx, float ry, float rw, float rh) {
  return px >= rx && px <= rx + rw && py >= ry && py <= ry + rh;
  //if (px >= rx && px <= rx + rw && py >= ry && py <= ry + rh) return true;
  //else return false;
}

void mouseReleased() {
  int curTime = millis(), AIMov;
  if (curTime - lastMoveTime <= moveDispDur) return;
  for (int i = 0; i < 3; ++i)
    if (pointInRect(mouseX, mouseY, iconX[i], iconY[i], iconSize, iconSize)) {
      lastMoveTime = curTime;
      AIMov = AI_move();
      cmptMov.append(AIMov);
      plyrMov.append(i);
      switch (win[i][AIMov]) {
        case 1: ++plyrScore; break;
        case 0: break;
        case -1: ++cmptScore; break;
      }
      break;
    }
}

int AI_consideration = 9;
int AI_move() {
  float[] count = new float[3];
  float sum = 0;
  for (int i = max(0, plyrMov.size() - AI_consideration); i < plyrMov.size(); ++i) {
    ++count[plyrMov.get(i)]; ++sum;
  }

  // f(x) = 0.325 - x / 4      (0 <= x <= 0.5)
  //        120x^2 - 192x + 77 (0.5 <= x <= 1)
  for (int i = 0; i < 3; ++i) {
    float freq = count[i] / sum;
    if (freq <= 0.5) count[i] = 0.325 - freq / 2;
    else count[i] = (120 * freq - 192) * freq + 77;
  }
  sum = 0;
  for (int i = 0; i < 3; ++i) sum += count[i];
  for (int i = 0; i < 3; ++i) count[i] /= sum;
  // count is now the possibility that player will take this next
  println(count[0], count[1], count[2]);
  sum = random(1);
  // sum is now the randomly generated number for the decision
  if (sum < count[0]) return 2;
  else if (sum < count[0] + count[2]) return 1;
  else return 0;
}
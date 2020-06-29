//Integrate Various ODEs
//CSCI 5611 ODE/PDE Integration Sample Code
// Stephen J. Guy <sjguy@umn.edu>

//TODO:
// To help you get started, we've implemented Eulerian integration, RK4, and Heun's method for you.
// We've also implemented a special version of RK4 that returns a list of a list of all of the
//   intermediate values of x between t_start and t_end (for every dt sample).
// You need to implement:
//    -The basic midpoint method
//    -A version of midpoint integration which returns a list of intermediate values
//    -A version of Eulerian integration which returns a list of intermediate values

float dxdt(float t, float x) {
  return x;
}

//Eulerian Integration
//Assume the current slope dx/dt holds true for the entire range dt
float eulerian(float t_start, float x_start, int n_steps, float dt){
  float x = x_start;
  float t = t_start;
  for (int i = 0; i < n_steps; i++){
    x += dxdt(t,x)*dt;
    t += dt;
  }
  return x;
}

//Midpoint method
//Simulate forward 1/2 a timestep withe eulerian integration
//Compute the derivative at a 1/2 timestep ahead
//Use the derivative from a 1/2 timestep ahead back at the original state
float midpoint(float t_start, float x_start, int n_steps, float dt){
  float x = x_start;
  float t = t_start;
  for (int i = 0; i < n_steps; i++){
    float k1 = dxdt(t,x);
    float k2 = dxdt(t+dt/2,x+dt*k1/2);
    float k3 = dxdt(t+dt,x+dt*k2);
    x += (k1+2*k2+k3)*dt/4;
    t += dt;
  }
  return x;
}

//RK4 - or "The Runge–Kutta method"
//https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods#The_Runge%E2%80%93Kutta_method
// It's esentially a mid-point of midpoints methods, and povide 4th order accuracy
// RK4 is very popular in practice as it provides a nice between stability and computational speed
float rk4(float t_start, float x_start, int n_steps, float dt){
  float x = x_start;
  float t = t_start;
  for (int i = 0; i < n_steps; i++){
    float k1 = dxdt(t,x);
    float k2 = dxdt(t+dt/2,x+dt*k1/2);
    float k3 = dxdt(t+dt/2,x+dt*k2/2);
    float k4 = dxdt(t+dt,x+dt*k3);
    x += (k1+2*k2+2*k3+k4)*dt/6;
    t += dt;
  }
  return x;
}

//Heun's method (https://en.wikipedia.org/wiki/Heun%27s_method)
//Use the current slope to predict the next x
//Find the slope at the next x
//Re-run the current x with the average of the current slope and the next slop
float heun(float t_start, float x_start, int n_steps, float dt){ //Heun's method
  float x = x_start;
  float t = t_start;
  for (int i = 0; i < n_steps; i++){
    float curSlope = dxdt(t,x);
    float x_next = x + curSlope*dt; //Take a normal Euler step, but then...
    float nextSlope = dxdt(t+dt,x_next); //Look at the slope at where we land.
    x += dt*(curSlope+nextSlope)/2; //Average the current slope and the expected next slope
    t += dt;
  }
  return x;
}

//Return's a list of the computed values from t_start to t_end using Eulerian integration
ArrayList<Float> eulerianList(float t_start, float x_start, int n_steps, float dt){
  ArrayList<Float> xVals = new ArrayList<Float>();
  float x = x_start;
  float t = t_start;
  xVals.add(x);
  for (int i = 0; i < n_steps; i++){
    x += dxdt(t,x)*dt;
    t += dt;
    xVals.add(x);
  }
  return xVals;
}

//Return's a list of the computed values from t_start to t_end using Midpoint integration
ArrayList<Float> midpointList(float t_start, float x_start, int n_steps, float dt){
  ArrayList<Float> xVals = new ArrayList<Float>();
  float x = x_start;
  float t = t_start;
  xVals.add(x);
  for (int i = 0; i < n_steps; i++){
    float k1 = dxdt(t,x);
    float k2 = dxdt(t+dt/2,x+dt*k1/2);
    float k3 = dxdt(t+dt,x+dt*k2);
    x += (k1+2*k2+k3)*dt/4;
    t += dt;
    xVals.add(x);
  }
  return xVals;
}

//Return's a list of the computed values from t_start to t_end using RK4 integration
ArrayList<Float> rk4List(float t_start, float x_start, int n_steps, float dt){
  ArrayList<Float> xVals = new ArrayList<Float>();
  float x = x_start;
  float t = t_start;
  xVals.add(x);
  for (int i = 0; i < n_steps; i++){
    float k1 = dxdt(t,x);
    float k2 = dxdt(t+dt/2,x+dt*k1/2);
    float k3 = dxdt(t+dt/2,x+dt*k2/2);
    float k4 = dxdt(t+dt,x+dt*k3);
    x += (k1+2*k2+2*k3+k4)*dt/6;
    t += dt;
    xVals.add(x);
  }
  return xVals;
}

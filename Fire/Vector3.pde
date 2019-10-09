public class Vector3 {
  
  public float x, y , z;
  
    public Vector3() {
      this.x = 0;
      this.y = 0;
      this.z = 0;
    }
    
    public Vector3(float x, float y, float z) {
      this.x = x;
      this.y = y;
      this.z = z;
    }
    
    public Vector3 add(Vector3 v) {
      float addx = this.x + v.x;
      float addy = this.y + v.y;
      float addz = this.z + v.z;
      return new Vector3(addx, addy, addz);
    }
    
    public Vector3 add(float x, float y, float z) {
      float addx = this.x + x;
      float addy = this.y + y;
      float addz = this.z + z;
      return new Vector3(addx, addy, addz);
    }
    
    public Vector3 mult(float v) {
      float multx = this.x * v;
      float multy = this.y * v;
      float multz = this.z * v;
      return new Vector3(multx, multy, multz);
    }
    
    public float dot(Vector3 v) {
      float xdot = this.x * v.x;
      float ydot = this.y * v.y;
      float zdot = this.z * v.z;
      return (xdot + ydot + zdot);
    }
    
    public Vector3 cross(Vector3 v) {
      float xcross = (this.y * v.z + this.z * v.y);
      float ycross = (this.z * v.x + this.x * v.z);
      float zcross = (this.x * v.y + this.y * v.x);
      return new Vector3(xcross, ycross, zcross);
    }
    
    public Vector3 normalize() {
      float mag = sqrt(sq(this.x) + sq(this.y) + sq(this.z));
      return new Vector3(this.x / mag, this.y / mag, this.z / mag);
    }
}
pragma solidity ^0.4.10;

// importing Oraclize API contract
import "./oraclizeAPI.sol";

/** @title Education Platform */
contract education is usingOraclize{


address authorized;
// for circuit breaker
bool emergency= false;
//The user struct to hold his address,name,email id and password
  struct user{
    address user_add;
    string name;
    string email;
    string password;
  }

/** The course request struct to hold the course request -id,name of course,course details,
 * fees,requester address,accepted status and the teacher who accepted the request
 */
 struct coursereq{
   bytes32 courseId;
   string name;
   string details;
   uint fees;
   address user_add;
   bool accepted;
   address teacher_add;
 }

// The bid for price of course struct which has the course request id, bid amount, bidder address and acceptance status
 struct bid{
   bytes32 courseid;
   uint amount;
   address bidder;
   bool accepted;
 }

// Course struct which has -course id,course name,course details, course fees and address of teacher
 struct course{
   bytes32 courseid;
   string name;
   string details;
   uint fees;
   address trainer;
 }

  //mapping of course id to course
  mapping (bytes32 => course) courseadding;
  //mapping address to user struct
  mapping(address => user) usermapping;
  //mapping user address to course request
  mapping(address => coursereq) coursemapping;
  //mapping course request id to course request
  mapping(bytes32 => coursereq) idtocoursemapping;
  //mapping course id to the bidders address
  mapping(bytes32 => address[]) coursetobid;
  //mapping address of user to his bid
  mapping(address => bid) addresstobid;
  //mapping course id to videos
  mapping (bytes32 => string[]) coursetovid;
  //mapping user added to courses he has taken
  mapping (address => bytes32[]) usertocourse;
  //mapping course id to course struct
  mapping (bytes32 => course) coursedetailmapping;
  //mapping users address to his name
  mapping (address => string) addresstoname;
  //mapping users address to the courses he created
  mapping (address => bytes32[]) usertocreated;
  //mapping user to his course request id's
  mapping (address => bytes32[]) usertoreq;
  //mapping course id to number of students
  mapping (bytes32 => uint) nooftakers;
  //mapping course id to amount paid till now
  mapping (bytes32 => uint) paidtillnow;


//constructor which sets authorized to the contract creator
 constructor() public {
   authorized=msg.sender;
 }

//modifier to check if the person is authorized
 modifier onlyAuthorized{
   require(authorized==msg.sender);
   _;
 }

//modifier to stop certain functions when in emergency
 modifier stoppedInEmergency {
   require(!emergency);
   _;
 }

//circuit breaker function to stop contract functioning
 function stopContract() onlyAuthorized {
   emergency=true;
 }

//resuming the contract when required
 function resumeContract() onlyAuthorized {
   emergency=false;
 }

// array to store requested courses
  bytes32[] requestedcourses;
  /** @dev Request for a course
    * @param reqname Name of the user
    * @param name Name of the course
    * @param details Course details
    */
  function request_course(string reqname,string name,string details) payable stoppedInEmergency {
    bytes32 id =keccak256(name,msg.sender);
    coursemapping[msg.sender]=coursereq(id,name,details,msg.value,msg.sender,false,0);
    idtocoursemapping[id]=coursereq(id,name,details,msg.value,msg.sender,false,0);
    requestedcourses.push(id);
    coursetobid[id]=[0];
    coursetovid[id]=["0"];
    addresstoname[msg.sender]=reqname;
    usertoreq[msg.sender].push(id);
  }

  /** @dev View course Requests
    * @return array of course reqeuest id's
    */
  function viewcourserequests() constant returns(bytes32[]) {
    return requestedcourses;
  }

  /** @dev View course Requests
    * @param id Request id
    * @return course id
    * @return course name
    * @return course details
    * @return course fees
    * @return address of the learner
    * @return course accepted by someone
    * @return address of the teacher
    */
  function viewcourserequestswithdetails(bytes32 id) constant returns (bytes32,string,string,uint,address,bool,address) {
     return (idtocoursemapping[id].courseId,idtocoursemapping[id].name,idtocoursemapping[id].details,idtocoursemapping[id].fees,idtocoursemapping[id].user_add,idtocoursemapping[id].accepted,idtocoursemapping[id].teacher_add);
  }

/** @dev Accept Course Request
  * @param id The course request id
  */
  function acceptcoursereq(bytes32 id) {
    idtocoursemapping[id].accepted=true;
    idtocoursemapping[id].teacher_add=msg.sender;
    usertocreated[msg.sender].push(id);

  }

  /** @dev Show course ids of courses the user is teaching
    * @return array of course id's
    */
  function showcreatedcourse() constant returns(bytes32[]) {
    return usertocreated[msg.sender];
  }

  /** @dev Show course ids of courses the user is learning
    * @return array of course id's
    */
  function showmycourses() constant returns(bytes32[]){
    return usertocourse[msg.sender];
  }


  /** @dev Show course ids of courses the user requested
    * @return array of course request id's
    */
 function showmycoursereq() constant returns(bytes32[]) {
   return usertoreq[msg.sender];
 }

 /** @dev Remove course requests
   * @param id The id of course request to remove
   */
 function removereq(bytes32 id) {
   require(idtocoursemapping[id].user_add==msg.sender);
   idtocoursemapping[id].accepted=true;
   msg.sender.transfer(idtocoursemapping[id].fees);
 }

 /** @dev Add video to course request
   * @param reqid Course request id
   * @param vidhash The ipfs video hash
   */
  function addvideo(bytes32 reqid,string vidhash) {
    require(idtocoursemapping[reqid].teacher_add==msg.sender);
    coursetovid[reqid].push(vidhash);
  }

  /** @dev Show course video by number
    * @param id Course id
    * @param i The link number
    */
  function showvideos(bytes32 id,uint i) constant returns(string) {
    for(var j=0;j<usertocourse[msg.sender].length;j++)
    {
      if(usertocourse[msg.sender][j]==id)
      {
        return coursetovid[id][i];
      }
    }

  }

  /** @dev The trainer gets money through this
    * @param id Course id
    */
  function paytrainer(bytes32 id) {
    require(coursedetailmapping[id].trainer==msg.sender);
    uint noofvid = showallvideos(id);
    uint fees= coursedetailmapping[id].fees;
    address trainer = coursedetailmapping[id].trainer;
    uint total = nooftakers[id]*fees;
    require(paidtillnow[id]<total);
    uint amounttogive = (fees-(paidtillnow[id]/nooftakers[id]))/(noofvid);
    paidtillnow[id]+=amounttogive;
    trainer.transfer(amounttogive);
  }

  /** @dev Show number of videos for the course
    * @param id Course id
    * @return the number of course
    */
  function showallvideos(bytes32 id) constant returns(uint) {
    return coursetovid[id].length;
  }

  /** @dev Add a course
    * @param reqname Your name
    * @param name Course name
    * @param description Some course description
    * @param fees Course fees
    */
  function newcourse(string reqname,string name,string description,uint fees) {
    bytes32 id =keccak256(name,msg.sender);
    coursetovid[id]=["0"];
    courseadding[id]=course(id,name,description,fees,msg.sender);
    allcourses.push(id);
    coursedetailmapping[id]= course(id,name,description,fees,msg.sender);
    addresstoname[msg.sender]=reqname;
    usertocreated[msg.sender].push(id);
  }

bytes32 public oraclizeID;
string public result;

/** @dev Function to trigger oraclize and convert to usd
  * @param value the value of wei to convert
  */
 function convertToUsd(uint value) payable{
   oraclizeID = oraclize_query("WolframAlpha","Convert 1 ether to usd");
 }

// function which oraclize calls
 function __callback(bytes32 _oraclizeID,string _result) {
   require(msg.sender==oraclize_cbAddress());
   result=_result;
 }

 /** @dev Retruns the value of result
   * @return value of result
   */
 function getresult() constant returns(string) {
   return result;
 }
  /** @dev Add video to course
    * @param id Course id
    * @param vid The ipfs video hash
    */
  function addvideotocourse(bytes32 id,string vid) stoppedInEmergency {
    require(coursedetailmapping[id].trainer==msg.sender);
    coursetovid[id].push(vid);
  }

  /** @dev Buy course
    * @param id Course id
    */
  function takecourse(bytes32 id) payable stoppedInEmergency{
    require(msg.value>=courseadding[id].fees);
    usertocourse[msg.sender].push(id);
    nooftakers[id]++;
  }

  //array to store all the courses
  bytes32[] allcourses;
  /** @dev Show all courses in the platform
    * @return array of course id's
    */
  function showallcourses() constant returns(bytes32[]) {
    return allcourses;
  }

  /** @dev Show all the course details
    * @param id Course id
    * @return course id
    * @return course name
    * @return course details
    * @return course fees
    * @return course teacher
    * @return course teacher name
    */
  function showcoursebyid(bytes32 id) constant returns(bytes32,string,string,uint,address,string) {
    return (coursedetailmapping[id].courseid,coursedetailmapping[id].name,coursedetailmapping[id].details,coursedetailmapping[id].fees,coursedetailmapping[id].trainer,addresstoname[coursedetailmapping[id].trainer]);
  }

//payable fallback functions
  function() payable stoppedInEmergency {

  }
}

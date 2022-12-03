var education = artifacts.require("./education.sol");
chai = require("chai");
chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
expect = chai.expect;

contract("Test the contract",function(accounts){
    describe("Deploy the smart contract",function(){
      it("Catch an instance of the contract",function(){
        return education.new().then(function (instance) {
           educontract=instance;
        });
      });
    });
    var id;
    describe("Check Course Requests",function(){
      it("Call function request_course",function(){
        return educontract.request_course("Tim","Blockchain","Solidity").then(function(res){
          expect(res).to.not.be.an("error");
        });
      });
      it("Check number of course requests",function(){
        return educontract.viewcourserequests().then(function(res){
          expect(res).to.be.lengthOf(1);
         id=res[0];
        });
      });
      it("Check course name",function(){
        return educontract.viewcourserequestswithdetails(id).then(function(res){
          expect(res[1].toString()).to.be.equal('Blockchain');
        });
      });
    });
    var id1;
    describe("Check Add Course",function(){
      it("Call function newcourse",function(){
        return educontract.newcourse("Robert","Javascript","Writing Tests",1000000).then(function(res){
          expect(res).to.not.be.an("error");
        });
      });
      it("Check number of courses",function(){
        return educontract.showallcourses().then(function(res){
          expect(res).to.be.lengthOf(1);
         id1=res[0];
        });
      });
      it("Check course name",function(){
        return educontract.showcoursebyid(id1).then(function(res){
          expect(res[1].toString()).to.be.equal('Javascript');
        });
      });
    });
    describe("Take the course",function(){
      it("Take the course-Javascript-paying less, should fail",function(){
        return expect(educontract.takecourse(id1,{from:accounts[1],value:100000}))
        .to.be.eventually.rejected;
      });
      it("Take the course-Javascript-paying actual amount ",function(){
        return educontract.takecourse(id1,{from:accounts[1],value:1000000}).then(function(res){
          expect(res).to.not.be.an("error");
        });
      });
    });
    describe("Acceptance of course requests",function(){
      it("Accept course request",function(){
        return educontract.acceptcoursereq(id,{from:accounts[2]}).then(function(res){
          expect(res).to.not.be.an("error");
        });
      });
      it("Course variables updated",function(){
        return educontract.viewcourserequestswithdetails(id).then(function(res){
          expect(res[5]).to.be.equal(true);
        });
      });
    });
    describe("Add video to course",function(){
      it("Other person than the acceptor trying to add a video-should fail",function(){
        return expect(educontract.addvideo(id,"QmcniBv7UQ4gGPQQW2BwbD4ZZHzN3o3tPuNLZCbBchd1zh",{from:accounts[3]}))
        .to.be.eventually.rejected;
      });
      it("Course acceptor adding a video",function(){
        return educontract.addvideo(id,"QmcniBv7UQ4gGPQQW2BwbD4ZZHzN3o3tPuNLZCbBchd1zh",{from:accounts[2]}).then(function(res){
          expect(res).to.not.be.an("error");
        });
      });
    });
    describe("Get Video links of a course",function(){
      it("Any other person gets the video links of the course-should not allow",function(){
        return educontract.showvideos(id,1,{from:accounts[4]}).then(function(res){
          expect(res).to.be.equal("");
        })
      })
    })
});

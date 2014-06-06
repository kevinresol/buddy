package buddy.tests ;
import buddy.BuddySuite;
import buddy.Buddy;
using buddy.Should;

#if neko
import neko.vm.Thread;
#elseif cs
import cs.system.timers.ElapsedEventHandler;
import cs.system.timers.ElapsedEventArgs;
import cs.system.timers.Timer;
#else
import haxe.Timer;
#end

class AllTests implements Buddy {}

class TestBasicFeatures extends BuddySuite
{
	private var testAfter : String;

	public function new()
	{
		describe("When testing before", {
			var a = 0;

			before({
				a = 1;
			});

			it("should set the variable a to 1 in before", {
				a.should.equal(1);
			});
		});

		describe("When testing after", {
			it("should not set 'testAfter' in the first spec", {
				testAfter.should.equal(null);
			});

			it("should call after before the second spec, and set 'testAfter'", {
				testAfter.should.equal("after executed");
			});

			after({
				testAfter = "after executed";
			});
		});

		describe("When testing ints", {
			var number = 3;

			it("should have a beLessThan method", {
				number.should.beLessThan(4);
			});

			it("beLessThan should compare against float", {
				number.should.beLessThan(3.1);
			});

			it("should have a beMoreThan method", {
				number.should.beGreaterThan(2);
			});

			it("beMoreThan should compare against float", {
				number.should.beGreaterThan(2.9);
			});
		});

		describe("When testing should().not", {
			it("should invert the test condition", {
				"a".should.not.equal("b");
			});
		});
	}
}

class TestAsync extends BuddySuite
{
	public function new()
	{
		describe("When testing async", {
			var a;

			#if neko
			before(function(done) {
				Thread.create(function() {
					Sys.sleep(0.1);
					a = 1;
					done();
				});
			});
			#elseif (js || flash)
			before(function(done) {
				Timer.delay(function() { a = 1; done(); }, 1);
			});
			#elseif cs
			// -net-lib c:\HaxeToolkit\haxe\lib\hxcs\3,1,1\netlib\net-40\System.dll
			before(function(done) {
				var t = new Timer(10);
				t.add_Elapsed(new ElapsedEventHandler(function(sender : Dynamic, e : ElapsedEventArgs) {
					t.Stop();
					a = 1;
					done();
				}));

				t.Start();
			});
			#else
				#error
			#end

			it("should set the variable a to 1 in before even though it's an async operation", {
				a.should.equal(1);
			});
		});
	}
}

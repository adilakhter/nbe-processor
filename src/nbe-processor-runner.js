/*
 * A JS script that runs ./nbe-processor.rb with the specified arguments. 
 */
var execFile = require('child_process').execFile
var args = process.argv.slice(2);

console.log('Running nbe-processor.rb with the following arguments: ', args);

execFile('./nbe-processor.rb', args, function(error, stdout, stderr) {
  if(stdout) {
    console.log('stdout:\n', stdout);
  }
  
  if(stderr) {
    console.log('stderr:\n', stderr );
  }

  if (error) {
    console.log('error:\n', error);
  }
})
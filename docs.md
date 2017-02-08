Using Forge
Forge uses a great new Javascript framework called TurboJS to speed up your sites.
However, to ensure TurboJS works properly, there are a few tips for writing great code.

• How it works
TurboJS caches all your HTML in a handy manifest file, and replaces pages when the user navigates to a page.
This makes your site super fast, and means a great experience for your users.
However, your site's Javascript, (if it uses any) will only be executed the first time the site loads.

• Running Javascript
Fortunately, TurboJS provides events for page changes. All you have to do is call your code on the 'page:change' event.
This way, your code is executed every time the page changes.

Old code:

<code><pre>
$(document).ready(function(){
  Your code here
})
</pre></code>

New code

<code><pre>
var myFunction = function(){
  // Your code here
}

$(document).ready(myFunction)
$(document).on('page:change', myFunction)
</pre></code>

• Twitter buttons
When you add a "Tweet this" button to your page, remember to add the "script" tag after it.
---
layout: post
title: Lecture 8--Doing Things That Don't Scale, PR, and How to Get Started
description: 阅读原文
published: true
category: YCombinator
---

> 原文地址：[Doing Things That Don't Scale, PR, and How to Get Started][Doing Things That Don't Scale, PR, and How to Get Started]

Thanks for having me! I'm Stanley, the founder of DoorDash. It's really amazing to be here, because it wasn't actually that long ago when I sat in your seats. I was class of 2014, graduated in CS, as well as my cofounder Andy. For those of you who don't know what DoorDash is, we're building an on-demand delivery network for local cities. I want to start off with this photo that I took a few months ago. This was the night when we just raised our series A. I took this photo as I was walking back to where I lived; I actually lived in Roble at the time on campus. I took this photo because I realized just how ridiculous the combination of things I was holding in my hand was at the time. I was holding my CS247 homework, my tax forms (it was April – so I had to fill out my tax forms), that yellow speeding ticket, and right below that was a $15 million piece of paper I had just signed from Sequoia. And that kind of summarizes just how ridiculous our journey has been, doing this while I was at Stanford, and then transitioning this to an actual startup. I want to share with you that story today.

It all began two years ago in a macaroon store. It was my junior year at Stanford during the fall quarter. At the time, I was really passionate about building technology for small business owners. I sat down with Chloe, the owner of Chantal Guillon, a macaroon store in Palo Alto at the time, just interviewing her, trying to get feedback on this prototype we'd been working on, and also just learning about what her problems were in general. It was during this meeting when Chloe first brought up this problem of delivery. I remember she brought down this really really thick booklet. She showed me pages and pages of delivery orders, and a lot of these orders she had to turn down because there was no way she could have fulfilled them. She had no drivers, and she ended up having to personally deliver all these orders. That was a very interesting moment for us.

Over the course of the next few weeks, we talked to around 150 to 200 small business owners, and when we brought up this idea of delivery, they kept agreeing with us; they would say, "You know, we don't have delivery infrastructure. It's such a huge pain for us. There aren't any good solutions out there." This led us to wonder, delivery is such a common thing, such an obvious thing; why hasn't anyone solved this yet? Like, we must be missing something here right? We thought it was maybe because people had already tried this in the past, but they failed because there wasn't consumer demand for this. We asked ourselves, "How can we test this hypothesis?" We were just a bunch of college kids at the time. We didn't own trucks or delivery infrastructure or anything like that; we couldn't just build a delivery company overnight right? So how could we test this assumption we had?

We decided to create a simple experiment with restaurant delivery. We spent about an afternoon just putting together a quick landing page. When I went on the Internet, I found some PDF menus of restaurants in Palo Alto. We stuck it up there and added a phone number at the bottom, which was actually our personal cell phone number. And that was it. We put up the landing page and called it PaloAltoDelivery.com. This is actually what it looked liked (PowerPoint slide): It was super simple, ugly, and honestly we weren't really expecting anything - we just launched it. What we wanted to see was just would we receive phone calls, and if we got enough phone calls, then maybe this delivery idea was worth pursuing.

So we put it up there; we weren't really expecting anything, and all of a sudden we got a phone call. Someone called! They wanted to order Thai food. And we're like, “This is a real order; we're going to have to do something about it.” So we're in our cars and we're like, "We're not doing anything right now, might as well swing by, pick up some Pad Thai, and let's try to see how this whole delivery thing works." And we did. We delivered it to some guy up on Alpine Road I remember. We asked him, "How did you hear about us, what do you do?" He told us he was a scholar, and then he handed me his business card and told me he was the author of a book called Weed the People. That was our first ever delivery. It was like the best delivery/worst delivery you could ever ask for.

And then yeah, the next day we got two more phone calls. The day after that we got five, then it became seven, and then it became ten. And then soon we began to gain traction on campus through PaloAltoDelivery.com which is pretty crazy, because think about it: This was just a landing page. You had to look up PDF menus to place your orders and then call in. This isn't exactly the most professional-looking site, yet we kept getting phone calls; we kept getting orders. And that's kind of when we knew that we were onto something. We knew we found a need people wanted when people were willing to put up with all of this.

I think another key point to remember is we launched this in about an hour. We didn't have any drivers; we didn't have any algorithms; we didn't have a backend; we didn't spend six months building a fancy dispatch system – we didn't have any of that. We just launched because at the beginning it's all about testing the idea, trying to get this thing off the ground, and figuring out if this was something people even wanted. And it's okay to hack things together at the beginning.

At YC there's a mantra we like to talk about that is doing things that don't scale. So at the beginning we were the delivery drivers. We would go to class, and then after we would go deliver food. We were the customer support; you know I sometimes had to take phone calls during lectures. We spent afternoons just going down University Avenue just passing out flyers trying to promote DoorDash. We didn't have any dispatch system so what we had to do was use Square to charge all of our customers. We used a Google Doc to keep track of our orders. We used Apple's Find My Friends to keep track of where all of our drivers were. You know, just stuff like that, just hacking together solutions to try to get this thing off the ground. In fact at one point we were growing so fast that Square actually shut us down because we were under suspicion for money laundering. I mean think about it, we were getting small chunks of $15-$20 orders coming in at a rapid pace. Luckily, my cofounder Tony worked at Square so he just emailed some buddies there and everything was solved.

Another thing about doing things that don't scale is it also allows you to become an expert in your business, like driving helped us understand how the whole delivery process worked. We used that as an opportunity to talk to our customers, talk to restaurants. We did dispatching which helped us figure out - you know, we manually dispatched our drivers and that helped us figure out what our driver assignment algorithms should look like. We did customer support ourselves, getting real-time feedback from customers. I remember for the first few months when we got started, we would manually email every single new customer at the end of every night asking how their first delivery went, and how they heard about us. We would personalize all these emails: If I saw someone order chicken skewers from Oren's Hummus, we would say "Oh I love Oren's Hummus. How are your chicken skewers? How did you hear about us?" Feedback like that was really valuable, and customers really appreciated that.

I remember this one time - this was during YC - we had just come out of a meeting with one of our restaurant partners, and we heard about this ice cream place that had just opened up on University Avenue called Cream, and we wanted to go try it out. Then all of a sudden, our cofounder back at our office/house texted us saying "Oh we need drivers on the road; we got a huge spike in demand." So we debated for maybe about 10 seconds if we should go get ice cream or should we go deliver. We obviously went to deliver, but that kind of became our motivation on scaling, like you know, if we would scale, then we could go get ice cream next time.

Now of course we scale across different cities. Now we have to worry about building automated solutions, building dispatch systems, and figuring out how to match demand and supply - all that fancy technology stuff. But none of that mattered at the beginning because at the beginning it's all about getting the thing off the ground, and trying to find product-market fit.

Just to summarize, there are three things I would say I learned from doing DoorDash. First, test your hypothesis. You want to treat your startup ideas like experiments. The second thing is, launch fast. We launched in less than an hour with a really simple landing page. And finally, it's okay to do things that don't scale. Doing things that don't scale is one of your biggest competitive advantages when you're starting out, and you can figure out how to scale once you have your demand. And then maybe once you've scaled, then you go get that ice cream. Thank you

Q: How did your first customer hear about you?

A: Our very first one, I have no idea. We just launched in Palo Alto; we didn't do any marketing, so I assume he just must have typed in “Palo Alto delivery” into the web browser. And then after that, we did barely any marketing. I think I sent out one email to my dorm, and that was about it. It was all through word-of-mouth. And that kind of just validates how strong the need we found was when people are just talking about you, and willing to put up with a terrible user experience, terrible design, and stuff like that.

Q: When you started, it seemed so obvious to you, you were wondering why, what the reason was nobody had done this before. What's your answer now looking back?

A: Looking back I think the biggest thing is mobile. Now everyone has one of those in their pocket, and we saw that trend and thought what if you could design a delivery system that was entirely based off mobile, where you didn't have to have any infrastructure, or delivery fleets. Instead of hiring drivers full-time or purchasing vehicles, what if you could tap into more of an on-demand pool of independent contractors, and only send orders to them when they have time. So that's kind of the insight we had; everything was done through mobile.

Q: Did you know you were going to be a startup, or were you just making some money at first?

A: At the time we were all just really passionate about building technology for small business owners, and obviously this delivery thing came out of an experiment with the landing page. It was literally an experiment. We weren't expecting anything, and it just took off, and we just went with it. And logistics was always something we were really passionate about as well, like logistics of transportation – the perfect fusion of how you can help small business owners through delivery.

Q: Did you launch the mobile site first or the website?

A: We started with this landing page right here which took us about an hour to launch.

Q: How does DoorDash stand out amongst a very competitive space?

A: At the beginning consumer demand was never a problem, even up until now. So for us it's just about finding a need and just focusing on serving that demand. At the beginning competition doesn't really matter.

Q: How long did it take you to get incorporated into a company?

A: We launched in January 2013, and then we did YC that very summer. When we decided to take this idea through YC, we incorporated.

Q: Where do you plan to go beyond food delivery?

A: For us when we started DoorDash, it was always about helping small business owners and figuring out how you served this for any local merchant whether you were a macaroon store, restaurant, or furniture shop. That's still our focus; that's our long-term vision. For now we are just focused on restaurant delivery as a way to scale, but ultimately that's where we want to end up in.

Sam Altman: Next is Walker Williams, founder of Teespring. He's been working with YC for about a year and a half, something like that. I almost rejected him, which sounds like a dumb idea, but now they're making hundreds of millions of dollars in revenue, so very luckily I did not. Walker is also going to talk about doing things that don't scale.

Walker: Thank you guys for having me! My name is Walker; I am the CEO/Founder of Teespring. For those of you who don't know what Teespring is, we are an e-commerce platform that allows entrepreneurs to launch products and apparel brands without risk, cost, or compromise. Today the company is about 180 folks and we ship tens of thousands of products each day. I want to talk to you about one of the most fundamental advantages you have as a start up, and that's that you are able to do things that don't scale.

I define things that don't scale as things that are sort of fundamentally unsustainable; they will not last; they will not bring in the millionth user. Where they break, it's usually time but it could be a number of other things. But it's really growth strategies that won't take you to a million users. There are three places I want to focus on today. First one is finding your first users. The second one is turning those users into champions, and the third one is finding your product/market fit.

So finding your first users: The first thing you have to understand is that there's no silver bullet for user acquisition. You know, everybody, and this includes me when we got started, looks for that dream solution, that paperclip campaign that has tremendous ROI, some accelerating partnership that's going to springboard you into the stratosphere, and affiliate agreement; something that solves it for you. But the reality is for the vast majority of companies and in fact for every company that I've had the chance to speak to the CEO of, that's just not possible - those are unicorns. And most of the companies that from the outside look like they've had this dream growth curve, the reality is that those first users were impossibly hard to get. Let me tell you about the story about this ridiculously unsustainable business.

So this is Teespring in 2012 (PowerPoint). When we first launched, the business couldn't have looked worse. It took days of meetings; we had to offer free designs, and days of revisions back-and-forth, we'd have to launch the product ourselves, we'd have to do the social media, all to sell about 50 shirts to a local nonprofit and generate about $1000 of revenue. Anybody looking in would've said, "You guys have to give up, this is a terrible idea." But as time went on, those users started to add up, and I think something you have to understand is when you first launch a company, just by virtue of the fact that it's a new product, you're going to be bad at selling it right? You've got no idea what the pain points of customers really are. You've never sold that before. You don't have any success stories to point to, or testimonials. Those first users are always going to be the hardest.

And so it's your responsibility as a founder to do whatever it takes to bring in your first users. It's going to be different for every company. The common thread that I hear is, founders need to spend personal time and effort, a lot of their personal time and effort to bring those users in themselves. It could mean a number of things - anything from sending 100 emails a day, getting on the phone and just calling as many people as you can, going through a network like Stanford or Y Combinator. Anything you can do to just get that first user. I really equate it to pushing a boulder uphill. And if you think of a smooth hill when you get started, the incline is the steepest and those first inches are the hardest. But over time as you get farther and farther, the incline steadies out, it gets easier, and eventually you reach a point where you're at the top of the hill and the boulder starts to roll on its own.

And so for those first users, you cannot just focus on ROI in the sense of time. Do not expect to spend an hour and return thousands of dollars. Maybe Stanley was one of those unicorns - really incredible story. But for most of us, those first two users are going to take a lot of handholding, a lot of personal love, and that's okay - that's essential for building a company. The one caveat of that is, I don't recommend giving your product for free. And there are plenty of exceptions to this rule, but in general, cutting costs or giving the product away is an unsustainable strategy I wouldn't recommend. You need to make sure that users value your product. And you know, people treat products that are free in a much different way than a paid product, and often times it can give you a false sense of security like, "Oh we're getting all these users; surely we can convert them to paid."

The second aspect is what happens when you get those users? How do you turn those users into champions? A champion is a user who talks about and advocates for your product. Every company with a great growth strategy has users who are champions. The easiest way to turn a user into a champion is to the delight them with an experience they are going to remember, so something that's unusual or out of the ordinary – an exceptional experience.

The easiest way to do this early, and again something that is completely unsustainable - it's not going to scale forever - is to just talk to those users. People will say this all the time, it's sort of the core tenant of Y Combinator, is talk to users. I cannot stress how important it is that you spend a large chunk of your time talking to users. You should do it constantly, every single day, and as long as possible. Today at Teespring, I'm still the catchall email address, so anytime anybody misspells "support" or writes an email address that doesn't exist, I get that email. And so I still do about 10 to 20 customer service tickets every single day; I spend hours each night reading every single tweet, probably a little bit OCD, but that's okay; I read through all the Teespring communities. You're never going to get a better sense for your products than actually listening to real users. Especially in the early days, the product and the feature set you launch with is almost certainly not going to be the feature set that you scale with. So the quicker you talk to users and learn what they actually need, the faster you can get to that point.

There are three ways to talk to your customers. You can run customer service yourself. Up until Teespring was doing about $130-$140,000 a month, my cofounder Evan and I did everything in customer service. This is one where there's going to be an instinct to quickly pass off, and that's because it's painful. Even today when I open our customer service portal, I have an emotional reaction where my stomach sinks because it sucks talking to so many users who have had a terrible experience, and it's painful that something that you love and put so much effort into, to know you got it wrong or somebody didn't treat them right. But it's so important that you go through that and learn what you need to build, and what you need to fix.

The second step is to proactively reach out to current and churn customers. Churn customers are customers who have left. This is one that often falls by the wayside in the pursuit of new customers, but you want to make sure that your customers are having consistent good experiences; you don't want to take your current users for granted. When a user actually leaves your service, you want to reach out and find out why, both because that personal outreach can make the difference between leaving and staying; sometimes people just need to know that you care and it's going to get better. And even if you can't bring them back, there's a chance that you can learn from the mistakes you made that caused them leave, and fix it so you don't churn users out in the future in the same way.

Finally, the one I'm probably most OCD about is social media and communities. You need to know how people are talking about your brand. You need to try to make sure that when somebody does have a bad experience, and they're talking about it, that you make it right. Problems are inevitable: You're not going to have the perfect product; things are going to break; things are going to go wrong. That's not important. What's important is to always make it right, to always go the extra mile and make that customer happy. One detractor who's had a terrible experience in your platform is enough to reverse the progress of 10 champions. That's all it takes, is one to say, "No you shouldn't use those guys for X reasons," to ruin a ton of momentum.

There are examples in the early days where we would mess up massive orders. We'd print out colors slightly wrong; it would be the wrong size, and it would be half of our GMV for that month. We would know we got it wrong, and the customer would be unhappy, and the instinct was to say that it was only a little bit off, not completely wrong, or that it would be fine. But the reality is you just have to bite the bullet and make sure it's right. And the customers who are originally the most frustrated tend to turn into the biggest champions and the longest term users.

The last one I want to talk about is finding product/market fit. What I mean by that is the product you launch with will almost certainly not be the product that takes you to scale. So your job in those early days of a startup is to progress and iterate as fast as possible to reach that product that does have market fit. And as engineers your instinct is building a platform that's beautiful, clean-code, and that scales. You don't want to write a duct tape code that's going to pile on technical debt. But you need to optimize for speed over scalability and clean code. An example of this is in the early days, we had a couple enterprise customers come in, sort of bigger nonprofits, and say "Hey, we really like your service, but you're missing these fundamental things, so we're not going to use it." And we looked at what it would take to build out those features, and we weren't sure if they were going to work out long-term, but we wanted to try it.
































[NingG]:    http://ningg.github.com  "NingG"




[Doing Things That Don't Scale, PR, and How to Get Started]:						http://genius.com/Walker-williams-lecture-8-doing-things-that-dont-scale-pr-and-how-to-get-started-annotated






















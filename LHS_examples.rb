# # An alarm system.
# 
# To fully use Ruleby, the main point is to know precisely how to write LHS. The courrent DSL should change in the future, but let's talk of
# how it works today.
# 
# Let's demonstrate this with rules for an alarm system for a fabric or computer room. First if someone push the alarm button, bell rings.
# 
# ## A simple (but wrong way) of ringing on button push.
# 
# Let say the button call method 'push' or 'release' when it changes state. The "name" is just here to show how to use binding feature :
# 

# Add to fact a Pushed button
def push
  assert( Button.new(:name => "alarm", :status=>:pushed) )
end

# Add to fact a Released button
def release
  assert( Button.new(:name => "alarm", :status=>:released) )
end

# The rule that process pushed buttons. No priority for this 1st exemple
rule :buttonPush, 
  # Here, you __need__ to understand that `method` is in fact the instance of Button that is currently matched against this pattern.
  # you can prononce it like :
  #
  # > _When I get Button event, I associate it with :button key of context, I call its method `name` and associate the result to
  #   :button\_name key of context, I check if its method `status` return `:pushed`. If yes, launch action._ 
  [Button,:button,{method.name=>:button_name}, method.status==:pushed] do |context|
    # Here we acces to value binded to the context hash
    button      = context[:button]
    button_name = context[:button_name]
    # Name can be used to log
    Logger.info("Button #{button_name} push handled at #{Time.now.to_s}")
    
    # Here we will need to define this "start_ringing" better... but one step at a time.
    start_ringing()
end

# Same kind of rule for button release. We do not use button_name here to show an other way of accessing object
rule :buttonRelease, 
  [Button,:button, method.status==:released] do |context|
    button      = context[:button]
    Logger.info("Button #{button.name} release handled at #{Time.now.to_s}")    
    # But... wait ! There is a start and a stop, maybe this mean there is a kind of "state", ie : is_ringing, for the ring ? .
    stop_ringing()
end

#
# ## Why is this wrong ?
# In this example facts are only added. After one push and one release you will find in the fact database two `Button` objects.
# One pushed, the other one released which is an inconsistent state. Furthermore the ring state is not handled but left to mystery 
# of `start_ringing` and `stop_ringing`. What if we want to write rules that use the ringing state ?
# 1st things, let's clean fact database. We have two possibilities.
# 
# ### retract facts in the rules.
# This is something we have to know, but maybe not the best thing to do here. Exemple with the buttonRelease rule
rule :buttonRelease, 
  [Button,:button, method.status==:released] do |context|
    button      = context[:button]
    Logger.info("Button #{button.name} release handled at #{Time.now.to_s}")    
    # But... wait ! There is a start and a stop, maybe this mean there is a kind of "state", ie : is_ringing, for the ring ? .
    stop_ringing()
    # Here we do :
    retract button
end


# 
# 
# ### Maintain a external state.
#
# ### Maintain an internal state in facts database
#  

# # Aren't we mixing states and events ?
# Button convey a state and is used when something change... It is used as an event ! Sent in the fact database when there is a change.
cStack = {}
cStack.__index = cStack

function cStack.new()
	local self = setmetatable({}, cStack)
	self.m_Stack = {}
	return self
end



function cStack:Push(a_Value)
	table.insert(self.m_Stack, a_Value)
end



function cStack:Pop()
	local value = self.m_Stack[#self.m_Stack]
	self.m_Stack[#self.m_Stack] = nil
	return value
end

local component = require("component")
local event = require("event")
local unicode = require("unicode")
local ecs = require("ECSAPI")
local gpu = component.gpu

local context = {}

local separatorColor = 0xcccccc
local shortcutAutism = 3

----------------------------------------------------------------------------------------------------------------

--ОБЪЕКТЫ
local obj = {}
local function newObj(class, name, ...)
	obj[class] = obj[class] or {}
	obj[class][name] = {...}
end

function context.menu(x, y, ...)

	local data = {...}
	local sData = #data

	--Получаем размер экрана
	local xSize, ySize = gpu.getResolution()

	--Получаем самую жирную полоску текста
	local biggestElement = 0
	for i = 1, sData do
		if data[i] ~= "-" then
			local length = unicode.len(data[i][1])
			if data[i][3] then length = length + shortcutAutism  + unicode.len(data[i][3]) end
			biggestElement = math.max(biggestElement, length)
			length = nil
		end
	end

	--Задание ширины и высоты
	local width = 4 + biggestElement
	local height = sData

	--А это чтоб за края экрана не лезло
	if y + height >= ySize then y = ySize - height end
	if x + width + 1 >= xSize then x = xSize - width - 1 end

	--Рисуем окошечко и запоминаем, че было до него (сначала был Бог...!)
	local oldPixels = ecs.rememberOldPixels(x, y, x + width + 1, y + height)
	ecs.square(x, y, width, height, 0xffffff)
	ecs.windowShadow(x, y, width, height)
	gpu.setBackground(0xffffff)


	--Рисуем все элементы
	local counter = 0
	local yPos

	--Нарисовать конкретный элемент
	local function drawElement(i, background, foreground)

		if background then ecs.square(x, yPos, width, 1, background) end

		--Получаем текстик
		local text
		if data[i] == "-" then
			ecs.colorText(x, yPos, separatorColor, string.rep("─", width))
		else
			--Нужный цвет
			local color = foreground or 0x000000
			if data[i][2] then color = separatorColor end

			--Рисуем текстик
			ecs.colorText(x + 2, yPos, color, data[i][1])

			--Рисуем сокращение
			if data[i][3] then gpu.set(x + width - 2 - unicode.len(data[i][3]), yPos, data[i][3]) end

			newObj("Elements", i, x, yPos, x + width - 1, yPos)
		end
	end

	--Вообще все
	for i = 1, sData do
		yPos = y + counter

		drawElement(i)

		counter = counter + 1
	end

	--Проверка нажатия
	local action
	local e = {event.pull("touch")}
	for key, val in pairs(obj["Elements"]) do
		if ecs.clickedAtArea(e[3], e[4], obj["Elements"][key][1], obj["Elements"][key][2], obj["Elements"][key][3], obj["Elements"][key][4]) then
			yPos = e[4]
			drawElement(key, ecs.colors.blue, 0xffffff)
			os.sleep(0.3)
			action = data[key][1]
			break
		end
	end

	--Красим то, че было
	ecs.drawOldPixels(oldPixels)

	--Возвращаем выбранное
	return action

end

----------------------------------------------------------------------------------------------------------------

-- while true do
-- 	local e = {event.pull("touch")}
-- 	ecs.prepareToExit()
-- 	local action = context.menu(e[3], e[4], {"Показать содержимое"}, "-", {"Вырезать", false, "^X"}, {"Копировать", false, "^C"}, {"Вставить", true, "^V"}, "-", {"Переименовать"}, {"Создать ярлык"}, {"Добавить в архив"}, "-", {"Удалить", false, "⌫"})
-- 	ecs.prepareToExit()
-- 	print("Ты выбрал = "..tostring(action))
-- end

return context









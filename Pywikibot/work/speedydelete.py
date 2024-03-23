import pywikibot

site = pywikibot.Site("en", "warcraftwiki")
url = 'https://warcraft.wiki.gg'

sd = {
	"API ModelSceneFrameActorBase SetModelByCreatureDisplayID ",
	"API ModelSceneFrameActorBase SetDesaturation ",
	"API ModelSceneFrameActorBase SetAnimationBlendOperation ",
	"API ModelSceneFrameActorBase SetAnimation ",
	"API ModelSceneFrameActorBase SetAlpha ",
	"API ModelSceneFrameActorBase PlayAnimationKit ",
	"API ModelSceneFrameActorBase IsVisible ",
	"API ModelSceneFrameActorBase IsUsingCenterForOrigin ",
	"API ModelSceneFrameActorBase IsShown ",
	"API ModelSceneFrameActorBase IsLoaded ",
	"API ModelSceneFrameActorBase Hide ",
	"API ModelSceneFrameActorBase GetYaw ",
	"API ModelSceneFrameActorBase GetSpellVisualKit ",
	"API ModelSceneFrameActorBase GetScale ",
	"API ModelSceneFrameActorBase GetRoll ",
	"API ModelSceneFrameActorBase GetPosition ",
	"API ModelSceneFrameActorBase GetPitch ",
	"API ModelSceneFrameActorBase GetParticleOverrideScale ",
	"API ModelSceneFrameActorBase GetModelUnitGUID ",
	"API ModelSceneFrameActorBase GetModelPath ",
	"API ModelSceneFrameActorBase GetModelFileID ",
	"API ModelSceneFrameActorBase GetMaxBoundingBox ",
	"API ModelSceneFrameActorBase GetDesaturation ",
	"API ModelSceneFrameActorBase GetAnimationVariation ",
	"API ModelSceneFrameActorBase GetAnimationBlendOperation ",
	"API ModelSceneFrameActorBase GetAnimation ",
	"API ModelSceneFrameActorBase GetAlpha ",
	"API ModelSceneFrameActorBase GetActiveBoundingBox ",
	"API ModelSceneFrameActorBase ClearModel ",
}

def main():
	for v in sd:
		page = pywikibot.Page(site, v)
		page.text = "{{sd|bot mistake|~~~~}}\n\n"+page.text
		page.save(summary="speedydelete bot mistake")
		# time.sleep(5)
	print("done")

if __name__ == "__main__":
	main()

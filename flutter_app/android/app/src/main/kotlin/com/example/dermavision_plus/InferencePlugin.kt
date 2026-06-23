package com.example.dermavision_plus

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.pytorch.IValue
import org.pytorch.Module
import org.pytorch.Tensor
import java.io.File
import java.io.FileOutputStream

class InferencePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var module: Module? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "dermavision/inference")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadModel" -> {
                val assetPath = call.argument<String>("assetPath")!!
                try {
                    val modelPath = copyAssetToFile(assetPath)
                    module = Module.load(modelPath)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("LOAD_ERROR", "Failed to load model: ${e.message}", null)
                }
            }
            "predict" -> {
                val imagePath = call.argument<String>("imagePath")!!
                val mod = module
                if (mod == null) {
                    result.error("NOT_LOADED", "Model not loaded. Call loadModel first.", null)
                    return
                }
                try {
                    val opts = BitmapFactory.Options().apply { inPreferredConfig = Bitmap.Config.ARGB_8888 }
                    var bitmap = BitmapFactory.decodeFile(imagePath, opts)
                        ?: throw Exception("Cannot decode image at $imagePath")

                    // Fix EXIF rotation — disabled temporarily to match notebook (no EXIF correction)
                    // bitmap = correctExifOrientation(bitmap, imagePath)

                    println("[DermaVision] Image size after EXIF fix: ${bitmap.width}x${bitmap.height}")

                    // Match Python: transforms.Resize((224, 224)) — direct resize, no crop
                    val resized = Bitmap.createScaledBitmap(bitmap, 224, 224, true)

                    // Debug: sample the center pixel to confirm image loaded correctly
                    val samplePixel = resized.getPixel(112, 112)
                    val sr = (samplePixel shr 16) and 0xFF
                    val sg = (samplePixel shr 8) and 0xFF
                    val sb = samplePixel and 0xFF
                    println("[DermaVision] Center pixel RGB: r=$sr g=$sg b=$sb")

                    // Manual preprocessing — exactly matches Python's ToTensor() + Normalize()
                    // ToTensor: pixel / 255.0
                    // Normalize: (value - mean) / std
                    // Layout: CHW float32, shape [1, 3, 224, 224]
                    val H = 224
                    val W = 224
                    val pixels = IntArray(H * W)
                    resized.getPixels(pixels, 0, W, 0, 0, W, H)

                    val mean = floatArrayOf(0.485f, 0.485f, 0.485f)
                    val std  = floatArrayOf(0.229f, 0.229f, 0.229f)
                    val floatArray = FloatArray(3 * H * W)

                    for (i in pixels.indices) {
                        val pixel = pixels[i]
                        val r = ((pixel shr 16) and 0xFF) / 255.0f
                        val g = ((pixel shr  8) and 0xFF) / 255.0f
                        val b = ((pixel       ) and 0xFF) / 255.0f
                        floatArray[i]           = (r - mean[0]) / std[0]  // R plane
                        floatArray[H * W + i]   = (g - mean[1]) / std[1]  // G plane
                        floatArray[2 * H * W + i] = (b - mean[2]) / std[2] // B plane
                    }

                    val inputTensor = Tensor.fromBlob(floatArray, longArrayOf(1, 3, H.toLong(), W.toLong()))
                    val output = mod.forward(IValue.from(inputTensor)).toTensor()
                    val scores = output.dataAsFloatArray

                    println("[DermaVision] Raw logits[0..4]: ${scores.slice(0..4).joinToString { "%.3f".format(it) }}")

                    result.success(scores.map { it.toDouble() })
                } catch (e: Exception) {
                    result.error("PREDICT_ERROR", "Prediction failed: ${e.message}", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun correctExifOrientation(bitmap: Bitmap, imagePath: String): Bitmap {
        return try {
            val exif = ExifInterface(imagePath)
            val orientation = exif.getAttributeInt(
                ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL
            )
            val matrix = Matrix()
            when (orientation) {
                ExifInterface.ORIENTATION_ROTATE_90  -> matrix.postRotate(90f)
                ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
                ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
                ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.postScale(-1f, 1f)
                ExifInterface.ORIENTATION_FLIP_VERTICAL   -> matrix.postScale(1f, -1f)
                else -> return bitmap
            }
            println("[DermaVision] Applied EXIF rotation: orientation=$orientation")
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        } catch (e: Exception) {
            bitmap
        }
    }

    private fun copyAssetToFile(assetPath: String): String {
        val file = File(context.filesDir, assetPath)
        file.parentFile?.mkdirs()
        if (!file.exists()) {
            context.assets.open("flutter_assets/$assetPath").use { input ->
                FileOutputStream(file).use { output ->
                    input.copyTo(output)
                }
            }
        }
        return file.absolutePath
    }
}

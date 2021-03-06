import com.tinkerforge.IPConnection;
import com.tinkerforge.BrickletLEDStrip;
import com.tinkerforge.TinkerforgeException;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

class ImagesListener implements BrickletLEDStrip.FrameRenderedListener {
	private static final int CHUNK_SIZE = 16;
	private BrickletLEDStrip ledStrip = null;
	private short[][][][] images = null;
	private int imagePosition = 0;

	public ImagesListener(BrickletLEDStrip ledStrip, short[][][][] images) {
		this.ledStrip = ledStrip;
		this.images = images;
	}

	public void frameRendered(int length) {
		frameUpload();
		framePrepareNext();
	}

	private void frameUpload() {
		if (images.length == 0) {
			return;
		}

		// Reorder LED data into R, G and B channel
		short[] r = new short[Config.LED_ROWS*Config.LED_COLS];
		short[] g = new short[Config.LED_ROWS*Config.LED_COLS];
		short[] b = new short[Config.LED_ROWS*Config.LED_COLS];

		for (int row = 0, i = 0; row < Config.LED_ROWS; ++row) {
			int colBegin;
			int colEnd;
			int colStep;

			if (row % 2 == 0) {
				colBegin = Config.LED_COLS - 1;
				colEnd = -1;
				colStep = -1;
			} else {
				colBegin = 0;
				colEnd = Config.LED_COLS;
				colStep = 1;
			}

			for (int col = colBegin; col != colEnd; col += colStep) {
				r[i] = images[imagePosition][row][col][Config.R_INDEX];
				g[i] = images[imagePosition][row][col][Config.G_INDEX];
				b[i] = images[imagePosition][row][col][Config.B_INDEX];

				++i;
			}
		}

		// Make chunks of size 16
		short rChunk[] = new short[CHUNK_SIZE];
		short gChunk[] = new short[CHUNK_SIZE];
		short bChunk[] = new short[CHUNK_SIZE];

		for (int i = 0, k; i < Config.LED_ROWS*Config.LED_COLS; i += CHUNK_SIZE) {
			for (k = 0; k < CHUNK_SIZE && i + k < Config.LED_ROWS*Config.LED_COLS; ++k) {
				rChunk[k] = r[i + k];
				gChunk[k] = g[i + k];
				bChunk[k] = b[i + k];
			}

			try {
				ledStrip.setRGBValues(i, (short)k, rChunk, gChunk, bChunk);
			} catch (TinkerforgeException e) {
				break;
			}
		}
	}

	private void framePrepareNext() {
		if (images.length == 0) {
			return;
		}

		imagePosition = (imagePosition + 1) % images.length;
	}
}

public class Images {
	private static short[][][][] images = null;
	private static IPConnection ipcon = null;
	private static BrickletLEDStrip ledStrip = null;
	private static ImagesListener imagesListener = null;

	private static BufferedImage resizeImage(BufferedImage image, int width, int height) {
		BufferedImage resizedImage = new BufferedImage(width, height, image.getType());
		Graphics2D g = resizedImage.createGraphics();

		g.drawImage(image, 0, 0, width, height, null);
		g.dispose();

		return resizedImage;
    }

	private static short[][][] readImage(String imagePath) throws Exception {
		BufferedImage image = ImageIO.read(new File(imagePath));

		if (image.getWidth() != Config.LED_ROWS ||
		    image.getHeight() != Config.LED_COLS) {
			image = resizeImage(image, Config.LED_ROWS, Config.LED_COLS);
		}

		short[][][] pixel = new short[Config.LED_ROWS][Config.LED_COLS][3];

		for (int row = 0; row < Config.LED_ROWS; ++row) {
			for (int col = 0; col < Config.LED_COLS; ++col) {
				long rgb = image.getRGB(row, col);

				pixel[row][col][0] = (short)((rgb >> 16) & 0xFF);
				pixel[row][col][1] = (short)((rgb >>  8) & 0xFF);
				pixel[row][col][2] = (short)( rgb        & 0xFF);
			}
		}

		return pixel;
	}

	public static void main(String args[]) throws Exception {
		// Create IP Connection and connect it
		ipcon = new IPConnection();
		ipcon.connect(Config.HOST, Config.PORT);

		// Call a getter to check that the Bricklet is avialable
		ledStrip = new BrickletLEDStrip(Config.UID_LED_STRIP_BRICKLET, ipcon);

		try {
			ledStrip.getFrameDuration();
			System.out.println("Found: LED Strip " + Config.UID_LED_STRIP_BRICKLET);
		} catch (TinkerforgeException e) {
			System.out.println("Not Found: LED Strip " + Config.UID_LED_STRIP_BRICKLET);
			return;
		}

		// Read images
		images = new short[args.length][][][];

		for (int i = 0; i < args.length; ++i) {
			images[i] = readImage(args[i]);
		}

		// Set up listener and start rendering
		ledStrip.setFrameDuration(1000 / Config.IMAGES_FRAME_RATE);

		imagesListener = new ImagesListener(ledStrip, images);
		ledStrip.addFrameRenderedListener(imagesListener);

		imagesListener.frameRendered(0);

		System.out.println("Press key to exit"); System.in.read();
		ipcon.disconnect();
	}
}
